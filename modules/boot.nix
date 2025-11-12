{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Boot Configuration Module
  # Handles bootloader, kernel, initrd, and LUKS encryption setup
  ################################################################################

  ################################################################################
  # Bootloader - systemd-boot (UEFI)
  ################################################################################
  boot.loader = {
    # Use systemd-boot for UEFI systems
    systemd-boot = {
      enable = true;
      
      # Limit the number of generations in boot menu to save ESP space
      configurationLimit = 10;
      
      # Console resolution
      consoleMode = "auto";
      
      # Editor disabled for security (prevents tampering with boot parameters)
      editor = false;
      
      # Timeout for boot menu selection
      timeout = 3;
    };
    
    # Allow systemd-boot to modify UEFI variables
    efi.canTouchEfiVariables = true;
    
    # EFI system partition mount point
    efi.efiSysMountPoint = "/boot";
  };
  
  ################################################################################
  # Kernel Configuration
  ################################################################################
  boot = {
    # Use latest stable kernel with hardening patches
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Kernel parameters for optimization and hardware support
    kernelParams = [
      # Quiet boot for cleaner experience
      "quiet"
      
      # Show Plymouth splash screen
      "splash"
      
      # AMD CPU/GPU optimizations
      "amd_iommu=on"
      "iommu=pt"
      
      # Disable watchdog (optional, reduces unnecessary disk writes)
      "nowatchdog"
      
      # NVMe optimizations for better SSD performance
      "nvme_core.default_ps_max_latency_us=0"
      
      # Memory management optimizations
      "transparent_hugepage=madvise"
      
      # Security: enable mitigations for CPU vulnerabilities
      "mitigations=auto"
      
      # NVIDIA preparation (for future GPU addition)
      # These parameters will be harmless on AMD but required for NVIDIA
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];
    
    # Kernel modules to load at boot
    kernelModules = [
      # AMD graphics driver
      "amdgpu"
      
      # BTRFS filesystem support
      "btrfs"
      
      # KVM virtualization support
      "kvm-amd"
    ];
    
    # Additional kernel modules available in initrd
    initrd.availableKernelModules = [
      # NVMe driver (critical for boot from NVMe SSD)
      "nvme"
      
      # USB drivers
      "xhci_pci"
      "usbhid"
      
      # SATA/AHCI support (for compatibility)
      "ahci"
      "sd_mod"
      
      # AMD graphics (for early KMS)
      "amdgpu"
    ];
    
    # Kernel modules to load in stage 1 (initrd)
    initrd.kernelModules = [
      # Encryption support
      "dm-crypt"
      "dm-mod"
      
      # BTRFS support
      "btrfs"
      
      # AMD GPU for early display
      "amdgpu"
    ];
    
    # Supported filesystems
    supportedFilesystems = [
      "btrfs"
      "vfat"  # For EFI partition
      "ext4"  # For compatibility
      "ntfs"  # For reading Windows partitions
    ];
    
    ############################################################################
    # Kernel Hardening Parameters
    ############################################################################
    kernel.sysctl = {
      # Kernel hardening
      "kernel.dmesg_restrict" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.unprivileged_userns_clone" = 0;
      
      # Network hardening
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      
      # IP forwarding disabled (not a router)
      "net.ipv4.ip_forward" = 0;
      "net.ipv6.conf.all.forwarding" = 0;
      
      # Protect against SYN flood attacks
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_syn_retries" = 5;
      "net.ipv4.tcp_synack_retries" = 2;
      
      # Ignore ICMP ping requests (optional, comment out if you need ping)
      # "net.ipv4.icmp_echo_ignore_all" = 1;
      
      # Virtual memory tuning for desktop use
      "vm.swappiness" = 10;  # Minimize swap usage (we have 24GB RAM)
      "vm.vfs_cache_pressure" = 50;  # Less aggressive cache reclaim
      "vm.dirty_ratio" = 10;  # Percentage of RAM for dirty pages
      "vm.dirty_background_ratio" = 5;
    };
  };
  
  ################################################################################
  # systemd-initrd Configuration (Modern initrd implementation)
  ################################################################################
  boot.initrd.systemd = {
    enable = true;  # Enable systemd in initrd for better encryption handling
    
    # Emergency shell access (disable in production for security)
    emergencyAccess = true;
  };
  
  ################################################################################
  # LUKS Encryption Configuration
  ################################################################################
  boot.initrd.luks.devices = {
    # Main encrypted root partition
    cryptroot = {
      # Device to decrypt (will be set by hardware-configuration.nix)
      # This is a placeholder; actual UUID will be in hardware-configuration.nix
      device = "/dev/disk/by-uuid/PLACEHOLDER";
      
      # Allow discards (TRIM) for SSD longevity
      allowDiscards = true;
      
      # Performance optimization for NVMe SSDs
      bypassWorkqueues = true;
      
      # Enable LUKS2 features
      preLVM = true;
      
      # Crypttab options for optimal performance
      crypttabExtraOpts = [
        "discard"
        "no-read-workqueue"
        "no-write-workqueue"
      ];
    };
  };
  
  ################################################################################
  # Plymouth - Boot Splash Screen (Optional, Aesthetic)
  ################################################################################
  boot.plymouth = {
    enable = true;
    theme = "breeze";  # KDE Breeze theme for consistency
    
    # Logo displayed during boot
    logo = pkgs.fetchurl {
      url = "https://nixos.org/logo/nixos-logo-only-hires.png";
      sha256 = "1ivzgd7iz0i06y36p8m5w48fd8pjqwxhdaavc0pxs7w1g7mcy5si";
    };
  };
  
  ################################################################################
  # Early KMS (Kernel Mode Setting) for Smooth Boot
  ################################################################################
  # Enable early KMS for AMD graphics
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  ################################################################################
  # Tmpfs for /tmp (RAM-based temporary directory)
  ################################################################################
  boot.tmp = {
    # Use tmpfs for /tmp (faster, cleared on reboot)
    useTmpfs = true;
    
    # Size limit (4GB, can be adjusted)
    tmpfsSize = "4G";
    
    # Clean /tmp on boot
    cleanOnBoot = true;
  };
  
  ################################################################################
  # Boot Optimization
  ################################################################################
  # Reduce boot time by limiting systemd timeout
  systemd.extraConfig = ''
    DefaultTimeoutStopSec=10s
  '';
  
  # Faster shutdown
  systemd.services."systemd-poweroff".serviceConfig = {
    Type = "oneshot";
    TimeoutStartSec = "10s";
  };
  
  ################################################################################
  # Console Configuration During Boot
  ################################################################################
  boot.consoleLogLevel = 3;  # Show only errors and warnings during boot
  
  ################################################################################
  # Microcode Updates (AMD)
  ################################################################################
  # Enable AMD CPU microcode updates for security and stability
  hardware.cpu.amd.updateMicrocode = true;
  
  ################################################################################
  # Additional Boot Security
  ################################################################################
  # Restrict access to kernel logs
  boot.kernel.sysctl."kernel.dmesg_restrict" = 1;
  
  # Restrict loading kernel modules
  security.lockKernelModules = false;  # Must be false for graphics drivers
  
  ################################################################################
  # Notes and Future Enhancements
  ################################################################################
  # 
  # NVIDIA GPU Preparation:
  # When adding NVIDIA GPU in the future, uncomment and configure:
  # 
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   powerManagement.finegrained = false;
  #   open = false;  # Use proprietary driver for stability
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };
  # 
  # Also add CUDA support:
  # nixpkgs.config.cudaSupport = true;
  # 
  ################################################################################
}