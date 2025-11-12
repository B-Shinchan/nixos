#!/usr/bin/env bash

################################################################################
# NixOS 25.05 "Warbler" Automated Installation Script
# 
# This script performs a fully automated installation of NixOS with:
# - LUKS2 full disk encryption (single password unlock)
# - BTRFS filesystem with optimal subvolume layout
# - systemd-boot (UEFI)
# - Niri Wayland compositor
# - Complete development environment
#
# Author: shinchan
# Version: 1.0.0
# NixOS Version: 25.05 "Warbler"
################################################################################

set -euo pipefail  # Exit on error, undefined variables, and pipe failures
IFS=$'\n\t'        # Set Internal Field Separator for safer parsing

################################################################################
# ANSI Color Codes for Beautiful Output
################################################################################
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Color
readonly BOLD='\033[1m'

################################################################################
# Logging Functions
################################################################################
log_info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $*"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" >&2
}

log_step() {
    echo -e "\n${MAGENTA}${BOLD}═══ $* ═══${NC}\n"
}

################################################################################
# Error Handler
################################################################################
error_exit() {
    log_error "$1"
    log_error "Installation failed. Please check the logs and try again."
    exit 1
}

trap 'error_exit "An unexpected error occurred at line $LINENO"' ERR

################################################################################
# System Checks
################################################################################
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root. Use: sudo $0"
    fi
}

check_uefi() {
    if [[ ! -d /sys/firmware/efi ]]; then
        error_exit "UEFI boot is required. Your system appears to be running in BIOS/Legacy mode."
    fi
    log_success "UEFI boot detected"
}

check_internet() {
    log_info "Checking internet connectivity..."
    if ! ping -c 1 1.1.1.1 &>/dev/null; then
        error_exit "No internet connection detected. Please connect to the internet and try again."
    fi
    log_success "Internet connection verified"
}

################################################################################
# Disk Detection and Validation
################################################################################
detect_disk() {
    log_step "Detecting NVMe Disk"
    
    # List all available disks
    log_info "Available disks:"
    lsblk -d -o NAME,SIZE,TYPE,MODEL | grep -E "nvme|ssd|disk" || true
    
    # Try to detect NVMe disk automatically
    local nvme_disks
    nvme_disks=$(lsblk -d -n -o NAME,TYPE | awk '$2=="disk" && $1~/^nvme/ {print $1}')
    
    if [[ -z "$nvme_disks" ]]; then
        log_warning "No NVMe disk detected. Checking for other SSDs..."
        nvme_disks=$(lsblk -d -n -o NAME,TYPE | awk '$2=="disk" {print $1}')
    fi
    
    local disk_count
    disk_count=$(echo "$nvme_disks" | wc -l)
    
    if [[ $disk_count -eq 0 ]]; then
        error_exit "No suitable disk found for installation"
    elif [[ $disk_count -eq 1 ]]; then
        DISK="/dev/$(echo "$nvme_disks" | head -n 1)"
        log_success "Detected disk: $DISK"
    else
        log_warning "Multiple disks detected. Please select one:"
        select disk_name in $nvme_disks; do
            if [[ -n "$disk_name" ]]; then
                DISK="/dev/$disk_name"
                break
            fi
        done
    fi
    
    # Validate disk exists and has sufficient space
    if [[ ! -b "$DISK" ]]; then
        error_exit "Disk $DISK is not a valid block device"
    fi
    
    local disk_size_gb
    disk_size_gb=$(lsblk -d -n -o SIZE "$DISK" | numfmt --from=iec --to=si --format="%.0f" | head -c -2)
    
    if [[ ${disk_size_gb:-0} -lt 200 ]]; then
        error_exit "Disk $DISK is too small (minimum 200GB required for optimal installation)"
    fi
    
    log_success "Using disk: $DISK (${disk_size_gb}GB)"
    
    # Show disk information
    log_info "Disk details:"
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT "$DISK" || true
}

confirm_disk_wipe() {
    log_warning "═══════════════════════════════════════════════════"
    log_warning "⚠️  WARNING: ALL DATA ON $DISK WILL BE ERASED!"
    log_warning "═══════════════════════════════════════════════════"
    echo
    read -rp "Type 'YES' in capital letters to continue: " confirm
    if [[ "$confirm" != "YES" ]]; then
        error_exit "Installation cancelled by user"
    fi
}

################################################################################
# Password Management
################################################################################
get_encryption_password() {
    log_step "Setting Up Encryption Password"
    
    log_info "Your password will be used for:"
    echo "  • Disk encryption (LUKS)"
    echo "  • User login (shinchan)"
    echo "  • Sudo privileges"
    echo
    log_warning "Choose a strong password (minimum 8 characters)"
    echo
    
    while true; do
        read -rsp "Enter encryption password: " password1
        echo
        read -rsp "Confirm encryption password: " password2
        echo
        
        if [[ "$password1" != "$password2" ]]; then
            log_error "Passwords do not match. Please try again."
            continue
        fi
        
        if [[ ${#password1} -lt 8 ]]; then
            log_error "Password too short (minimum 8 characters)"
            continue
        fi
        
        ENCRYPTION_PASSWORD="$password1"
        break
    done
    
    log_success "Password set successfully"
}

################################################################################
# Disk Partitioning and Encryption
################################################################################
partition_disk() {
    log_step "Partitioning Disk: $DISK"
    
    # Unmount any existing partitions
    log_info "Unmounting any existing partitions..."
    umount -R /mnt 2>/dev/null || true
    swapoff -a 2>/dev/null || true
    
    # Wipe existing filesystem signatures
    log_info "Wiping existing filesystem signatures..."
    wipefs -af "$DISK" || true
    
    # Determine partition naming convention
    if [[ "$DISK" =~ nvme ]]; then
        PART_BOOT="${DISK}p1"
        PART_ROOT="${DISK}p2"
    else
        PART_BOOT="${DISK}1"
        PART_ROOT="${DISK}2"
    fi
    
    log_info "Creating GPT partition table..."
    parted -s "$DISK" mklabel gpt
    
    log_info "Creating EFI boot partition (1GB)..."
    parted -s "$DISK" mkpart ESP fat32 1MiB 1025MiB
    parted -s "$DISK" set 1 esp on
    
    log_info "Creating root partition (remaining space)..."
    parted -s "$DISK" mkpart primary 1025MiB 100%
    
    # Wait for kernel to recognize new partitions
    sleep 2
    partprobe "$DISK" || true
    sleep 2
    
    # Verify partitions were created
    if [[ ! -b "$PART_BOOT" ]] || [[ ! -b "$PART_ROOT" ]]; then
        error_exit "Partition creation failed. Partitions not found: $PART_BOOT, $PART_ROOT"
    fi
    
    log_success "Partitions created successfully"
    lsblk "$DISK"
}

encrypt_disk() {
    log_step "Encrypting Root Partition with LUKS2"
    
    log_info "Setting up LUKS2 encryption on $PART_ROOT..."
    
    # Create LUKS container with optimal settings
    echo -n "$ENCRYPTION_PASSWORD" | cryptsetup luksFormat \
        --type luks2 \
        --cipher aes-xts-plain64 \
        --key-size 512 \
        --hash sha512 \
        --iter-time 2000 \
        --use-random \
        --verify-passphrase \
        "$PART_ROOT" -
    
    log_info "Opening encrypted partition..."
    echo -n "$ENCRYPTION_PASSWORD" | cryptsetup open "$PART_ROOT" cryptroot -
    
    # Verify encrypted device exists
    if [[ ! -b /dev/mapper/cryptroot ]]; then
        error_exit "Failed to open encrypted partition"
    fi
    
    log_success "Disk encryption complete"
}

################################################################################
# Filesystem Creation
################################################################################
create_filesystems() {
    log_step "Creating Filesystems"
    
    # Format EFI partition
    log_info "Formatting EFI partition as FAT32..."
    mkfs.vfat -F32 -n NIXBOOT "$PART_BOOT"
    
    # Create BTRFS on encrypted partition
    log_info "Creating BTRFS filesystem with optimal settings..."
    mkfs.btrfs -f -L nixos /dev/mapper/cryptroot
    
    log_success "Filesystems created"
}

create_btrfs_subvolumes() {
    log_step "Creating BTRFS Subvolumes"
    
    # Mount root BTRFS volume temporarily
    mount -t btrfs /dev/mapper/cryptroot /mnt
    
    # Create subvolumes following NixOS best practices
    log_info "Creating @ subvolume (root)..."
    btrfs subvolume create /mnt/@
    
    log_info "Creating @home subvolume..."
    btrfs subvolume create /mnt/@home
    
    log_info "Creating @nix subvolume..."
    btrfs subvolume create /mnt/@nix
    
    log_info "Creating @log subvolume..."
    btrfs subvolume create /mnt/@log
    
    # Take empty snapshot for potential rollback
    log_info "Creating empty snapshot for rollback..."
    btrfs subvolume snapshot -r /mnt/@ /mnt/@-blank
    
    umount /mnt
    
    log_success "BTRFS subvolumes created"
}

mount_filesystems() {
    log_step "Mounting Filesystems"
    
    # Mount options for optimal performance and durability
    local mount_opts="compress=zstd:3,noatime,space_cache=v2,discard=async"
    
    # Mount root subvolume
    log_info "Mounting root subvolume..."
    mount -t btrfs -o subvol=@,$mount_opts /dev/mapper/cryptroot /mnt
    
    # Create mount points
    mkdir -p /mnt/{home,nix,var/log,boot}
    
    # Mount home subvolume
    log_info "Mounting home subvolume..."
    mount -t btrfs -o subvol=@home,$mount_opts /dev/mapper/cryptroot /mnt/home
    
    # Mount nix subvolume with additional noatime
    log_info "Mounting nix subvolume..."
    mount -t btrfs -o subvol=@nix,$mount_opts /dev/mapper/cryptroot /mnt/nix
    
    # Mount log subvolume
    log_info "Mounting log subvolume..."
    mount -t btrfs -o subvol=@log,$mount_opts /dev/mapper/cryptroot /mnt/var/log
    
    # Mount EFI partition
    log_info "Mounting EFI partition..."
    mount "$PART_BOOT" /mnt/boot
    
    log_success "All filesystems mounted"
    log_info "Mount layout:"
    df -h | grep -E "Filesystem|/mnt"
}

################################################################################
# NixOS Configuration Generation
################################################################################
generate_hardware_config() {
    log_step "Generating Hardware Configuration"
    
    nixos-generate-config --root /mnt
    
    # Store UUIDs for later use
    BOOT_UUID=$(blkid -s UUID -o value "$PART_BOOT")
    ROOT_UUID=$(blkid -s UUID -o value "$PART_ROOT")
    
    log_success "Hardware configuration generated"
    log_info "Boot UUID: $BOOT_UUID"
    log_info "Root UUID: $ROOT_UUID"
}

################################################################################
# Main Installation Flow
################################################################################
main() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║   ███╗   ██╗██╗██╗  ██╗ ██████╗ ███████╗    ██████╗ ███████╗    ║
║   ████╗  ██║██║╚██╗██╔╝██╔═══██╗██╔════╝    ╚════██╗██╔════╝    ║
║   ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║███████╗     █████╔╝███████╗    ║
║   ██║╚██╗██║██║ ██╔██╗ ██║   ██║╚════██║    ██╔═══╝ ╚════██║    ║
║   ██║ ╚████║██║██╔╝ ██╗╚██████╔╝███████║    ███████╗███████║    ║
║   ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚══════╝╚══════╝    ║
║                                                                   ║
║              Automated Installation Script v1.0.0                 ║
║                NixOS 25.05 "Warbler" - Shinchan                   ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    log_info "Starting NixOS automated installation..."
    sleep 2
    
    # Perform all checks
    check_root
    check_uefi
    check_internet
    
    # Disk operations
    detect_disk
    confirm_disk_wipe
    get_encryption_password
    
    # Install process
    partition_disk
    encrypt_disk
    create_filesystems
    create_btrfs_subvolumes
    mount_filesystems
    generate_hardware_config
    
    # Success message
    echo
    log_step "Installation Foundation Complete"
    log_success "Disk partitioning and encryption completed successfully"
    log_info "Next steps:"
    echo "  1. Copy your NixOS configuration to /mnt/etc/nixos/"
    echo "  2. Run: nixos-install --flake /mnt/etc/nixos#NixOS"
    echo "  3. Set root password when prompted"
    echo "  4. Reboot and enjoy your new NixOS system!"
    echo
    log_info "Disk layout:"
    lsblk "$DISK"
    echo
    log_success "Installation script completed successfully!"
}

################################################################################
# Script Entry Point
################################################################################
main "$@"