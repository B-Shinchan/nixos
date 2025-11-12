{ config, pkgs, lib, username, ... }:

{
  ################################################################################
  # User Management Module
  # User accounts, groups, and permissions configuration
  ################################################################################

  ################################################################################
  # User Account: shinchan
  ################################################################################
  users.users.${username} = {
    # This is a normal user account (not a system account)
    isNormalUser = true;
    
    # User description
    description = "Shinchan";
    
    # Home directory
    home = "/home/${username}";
    
    # Create home directory if it doesn't exist
    createHome = true;
    
    # Default shell (Fish shell for modern, user-friendly experience)
    shell = pkgs.fish;
    
    # User groups - provides various system permissions
    extraGroups = [
      "wheel"          # Sudo privileges
      "networkmanager" # Manage network connections
      "video"          # Access video devices (GPU, webcam)
      "audio"          # Access audio devices
      "input"          # Access input devices (mouse, keyboard)
      "disk"           # Access storage devices
      "storage"        # Access removable storage
      "optical"        # Access optical drives (CD/DVD)
      "scanner"        # Access scanners
      "bluetooth"      # Manage Bluetooth devices
      "lp"             # Manage printers
      "power"          # Power management
      "systemd-journal" # Read system logs
      "render"         # Access render nodes (GPU acceleration)
      "kvm"            # KVM virtualization
      "libvirtd"       # Libvirt virtualization management
      "docker"         # Docker container management (if enabled)
      "podman"         # Podman container management (if enabled)
    ];
    
    # User UID (optional, leave blank for automatic assignment)
    # uid = 1000;
    
    # Initial password (CHANGE THIS AFTER FIRST LOGIN!)
    # For security, this should be changed immediately after installation
    # The password is set during installation via nixos-install
    # which prompts for user password
    hashedPassword = null;  # Will be set during installation
    
    # OpenSSH authorized keys (if SSH is enabled)
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3... your-email@example.com"
    # ];
    
    # User-specific packages (installed in user profile)
    packages = with pkgs; [
      # User-level utilities
      # Most packages are installed system-wide or via home-manager
    ];
  };
  
  ################################################################################
  # Disable Root Login
  ################################################################################
  # For security, disable direct root login
  # Root access is available via sudo from the wheel group
  users.users.root = {
    hashedPassword = "!";  # Disable password login for root
    
    # Alternative: Set a root password during installation
    # This can be done via: sudo passwd root
    # Or during nixos-install
  };
  
  ################################################################################
  # User Groups Configuration
  ################################################################################
  users.groups = {
    # Ensure required groups exist
    ${username} = {};
    
    # Additional groups can be defined here if needed
    # Example: for custom service accounts
  };
  
  ################################################################################
  # Default User Shell - Fish
  ################################################################################
  # Make Fish available as a valid login shell
  programs.fish.enable = true;
  
  # Add Fish to /etc/shells
  environment.shells = with pkgs; [ fish bash zsh ];
  
  ################################################################################
  # User Environment Variables
  ################################################################################
  # These are set system-wide, but can be overridden per-user
  environment.variables = {
    # Editor preference
    EDITOR = "nvim";
    VISUAL = "nvim";
    
    # XDG Base Directory specification
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
  };
  
  ################################################################################
  # Home Directory Structure
  ################################################################################
  # NixOS automatically creates these standard directories in ~/:
  # - Desktop
  # - Documents
  # - Downloads
  # - Music
  # - Pictures
  # - Videos
  # - Public
  # - Templates
  
  # XDG user directories are managed by xdg-user-dirs
  environment.systemPackages = with pkgs; [
    xdg-user-dirs
  ];
  
  # Create custom directories on first login
  system.activationScripts.userDirectories = {
    text = ''
      # Create additional directories in user's home
      mkdir -p /home/${username}/{.config,.local/share,.local/state,.cache}
      mkdir -p /home/${username}/Pictures/Wallpapers
      mkdir -p /home/${username}/Pictures/Screenshots
      mkdir -p /home/${username}/Documents/{Projects,Work,Study,UPSC}
      mkdir -p /home/${username}/Downloads
      mkdir -p /home/${username}/Videos
      mkdir -p /home/${username}/Music
      mkdir -p /home/${username}/.ssh
      
      # Set proper ownership
      chown -R ${username}:${username} /home/${username}
      chmod 700 /home/${username}/.ssh
    '';
  };
  
  ################################################################################
  # Sudo Timeout Configuration
  ################################################################################
  # Configured in security.nix module
  # Users in wheel group can use sudo with password
  
  ################################################################################
  # User Session Management
  ################################################################################
  # PAM (Pluggable Authentication Modules) configuration
  security.pam.services = {
    # Configure login session
    login = {
      enableGnomeKeyring = true;  # Unlock GNOME Keyring on login
      
      # Store encryption password for LUKS unlock
      # This enables single-password unlock (login = disk unlock)
      text = lib.mkBefore ''
        auth optional ${pkgs.systemd}/lib/security/pam_systemd_loadkey.so
      '';
    };
    
    # Display manager PAM configuration (for Niri login)
    greetd = {
      enableGnomeKeyring = true;
      
      # Reuse LUKS password for keyring unlock
      text = lib.mkBefore ''
        auth optional ${pkgs.systemd}/lib/security/pam_systemd_loadkey.so
      '';
    };
  };
  
  ################################################################################
  # Auto-login Configuration (Optional - currently disabled for security)
  ################################################################################
  # For single-password unlock, we use PAM to unlock LUKS with login password
  # Auto-login would skip the password prompt, breaking the encryption unlock
  # 
  # If you want auto-login (NOT RECOMMENDED with encryption):
  # services.displayManager.autoLogin = {
  #   enable = false;
  #   user = username;
  # };
  
  ################################################################################
  # User Resource Limits
  ################################################################################
  security.pam.loginLimits = [
    # Prevent core dumps for all users
    {
      domain = "*";
      type = "hard";
      item = "core";
      value = "0";
    }
    
    # Maximum number of open files
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "131072";
    }
    
    # Maximum number of processes
    {
      domain = "*";
      type = "soft";
      item = "nproc";
      value = "32768";
    }
    {
      domain = "*";
      type = "hard";
      item = "nproc";
      value = "65536";
    }
    
    # Nice priority (lower = higher priority)
    {
      domain = "@wheel";
      type = "-";
      item = "nice";
      value = "-10";
    }
    
    # Real-time priority (for audio/video work)
    {
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "99";
    }
    {
      domain = "@video";
      type = "-";
      item = "rtprio";
      value = "99";
    }
  };
  
  ################################################################################
  # User Systemd Services
  ################################################################################
  # User-level systemd services are configured in home-manager (home.nix)
  # or in individual module files (e.g., wallpaper.nix)
  
  ################################################################################
  # GNOME Keyring Configuration
  ################################################################################
  services.gnome.gnome-keyring = {
    enable = true;
  };
  
  # Seahorse for keyring management GUI
  environment.systemPackages = with pkgs; [
    gnome-keyring
    seahorse  # GUI for managing keyrings
    libsecret # Secret management library
  ];
  
  ################################################################################
  # Notes for User Management
  ################################################################################
  # 
  # Password Management:
  # 1. Change user password: passwd
  # 2. Change root password: sudo passwd root
  # 3. Password requirements are enforced by PAM
  # 
  # Adding More Users:
  # To add additional users, copy the users.users.${username} block
  # and modify the username and settings accordingly
  # 
  # Group Permissions:
  # - wheel: sudo access
  # - networkmanager: manage WiFi/network
  # - video: access GPU for graphics
  # - audio: access sound devices
  # - input: access keyboard/mouse
  # - storage: mount USB drives
  # - kvm/libvirtd: run virtual machines
  # 
  # User Directories:
  # Standard XDG directories are created automatically
  # Custom directories are created by the activation script above
  # 
  # Shell Configuration:
  # Fish shell is configured in modules/shell/fish.nix
  # Alacritty terminal is configured in modules/shell/alacritty.nix
  # 
  ################################################################################
}