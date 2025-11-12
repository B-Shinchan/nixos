{ config, pkgs, inputs, username, hostname, ... }:

{
  ################################################################################
  # NixOS 25.05 "Warbler" - Main System Configuration
  # Hostname: NixOS | User: shinchan
  # Desktop: Niri (Wayland) | Hardware: AMD Ryzen 3 3200G
  ################################################################################

  ################################################################################
  # System State Version
  # DO NOT CHANGE - This tracks the NixOS release for compatibility
  ################################################################################
  system.stateVersion = "25.05";
  
  ################################################################################
  # Hostname Configuration
  ################################################################################
  networking.hostName = hostname;
  
  ################################################################################
  # Nix Configuration - Flakes and Experimental Features
  ################################################################################
  nix = {
    # Enable Flakes and the new nix command-line interface
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      
      # Automatically optimize the Nix store (removes duplicates)
      auto-optimise-store = true;
      
      # Allow the specified users to bypass certain restrictions
      trusted-users = [ "root" username ];
      
      # Warn about dirty Git trees during builds
      warn-dirty = false;
      
      # Substituters for binary caches (faster package installation)
      substituters = [
        "https://cache.nixos.org"
        "https://niri.cachix.org"  # Niri binary cache
        "https://nix-community.cachix.org"
      ];
      
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    
    # Automatic garbage collection to keep disk usage in check
    gc = {
      automatic = true;
      dates = "monthly";  # Run garbage collection monthly
      options = "--delete-older-than 15d";  # Keep last 15 days of generations
    };
    
    # Limit number of store generations to prevent disk bloat
    settings.max-free = 3000000000;  # 3GB free space target
    settings.min-free = 1000000000;  # 1GB minimum free space
  };
  
  ################################################################################
  # Package Configuration
  ################################################################################
  nixpkgs.config = {
    # Allow proprietary packages (VS Code, NVIDIA drivers, etc.)
    allowUnfree = true;
    
    # Package-specific configurations
    packageOverrides = pkgs: {
      # Ensure VS Code uses the official Microsoft build
      vscode = pkgs.vscode;
    };
  };
  
  ################################################################################
  # Locale and Internationalization
  ################################################################################
  # System locale
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Additional locale settings
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };
  
  # Support for Hindi input (though default is English)
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "en_IN/UTF-8"
    "hi_IN/UTF-8"
  ];
  
  ################################################################################
  # Console Configuration
  ################################################################################
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";  # US keyboard layout
    useXkbConfig = true;  # Use X keyboard configuration in console
  };
  
  ################################################################################
  # Timezone
  ################################################################################
  time.timeZone = "Asia/Kolkata";  # Indian Standard Time (IST)
  
  ################################################################################
  # XDG Portal Configuration (for Wayland/Niri)
  ################################################################################
  xdg.portal = {
    enable = true;
    # Use multiple portals for maximum compatibility
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk  # GTK portal for file choosers, etc.
      xdg-desktop-portal-wlr  # Wayland portal for screen sharing
    ];
    # Set Niri as the primary portal configuration
    configPackages = [ pkgs.niri ];
  };
  
  ################################################################################
  # PipeWire - Modern Audio System
  ################################################################################
  # Replace PulseAudio with PipeWire for better audio management
  security.rtkit.enable = true;  # RealtimeKit for low-latency audio
  services.pipewire = {
    enable = true;
    
    # Enable ALSA support
    alsa = {
      enable = true;
      support32Bit = true;  # 32-bit application support
    };
    
    # Enable PulseAudio compatibility layer
    pulse.enable = true;
    
    # Enable JACK support for professional audio
    jack.enable = true;
  };
  
  ################################################################################
  # Bluetooth Support
  ################################################################################
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;  # Power on Bluetooth on boot
    
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;  # Enable experimental features
      };
    };
  };
  
  # Bluetooth manager service
  services.blueman.enable = true;
  
  ################################################################################
  # Printing Support (CUPS)
  ################################################################################
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint hplip ];
  };
  
  ################################################################################
  # OpenGL and Graphics
  ################################################################################
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Support for 32-bit applications
    
    # AMD drivers for Ryzen 3 3200G (Vega 8 integrated graphics)
    extraPackages = with pkgs; [
      mesa
      mesa.drivers
      libva
      libvdpau-va-gl
      vaapiVdpau
    ];
  };
  
  ################################################################################
  # System-wide Environment Variables
  ################################################################################
  environment.variables = {
    # Default editor
    EDITOR = "nvim";
    VISUAL = "nvim";
    
    # XDG Base Directory Specification
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
    
    # Wayland-specific variables
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    
    # Qt styling for Wayland
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    
    # Mozilla Firefox Wayland support
    MOZ_ENABLE_WAYLAND = "1";
    
    # SDL2 Wayland support
    SDL_VIDEODRIVER = "wayland";
    
    # Java applications on Wayland
    _JAVA_AWT_WM_NONREPARENTING = "1";
    
    # NVIDIA-ready configuration (for future GPU addition)
    # These will be harmless on AMD but ensure NVIDIA compatibility
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
  
  ################################################################################
  # System Session Variables (for all users)
  ################################################################################
  environment.sessionVariables = {
    # Ensure Wayland is preferred
    NIXOS_OZONE_WL = "1";  # Enable Wayland for Chromium/Electron apps
  };
  
  ################################################################################
  # Enable dconf (required for GTK applications settings)
  ################################################################################
  programs.dconf.enable = true;
  
  ################################################################################
  # Polkit (required for privilege escalation in desktop environments)
  ################################################################################
  security.polkit.enable = true;
  
  # Polkit agent for Niri (using KDE's agent)
  systemd.user.services.polkit-kde-authentication-agent-1 = {
    description = "Polkit KDE Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
  
  ################################################################################
  # Essential System Packages
  ################################################################################
  environment.systemPackages = with pkgs; [
    # System utilities
    wget
    curl
    rsync
    unzip
    p7zip
    
    # File managers
    xfce.thunar  # GUI file manager
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    
    # Network tools
    networkmanagerapplet
    
    # Hardware information
    pciutils
    usbutils
    lshw
    
    # Process monitoring
    htop
    btop
    
    # Disk utilities
    gparted
    btrfs-progs
    
    # Text editors (basic)
    nano
    vim
    
    # Archive tools
    ark  # KDE archive manager
    
    # Clipboard manager for Wayland
    wl-clipboard
    
    # Screenshot utilities
    grim
    slurp
    
    # Notification daemon
    mako
    
    # Application launcher (for Niri)
    fuzzel
    
    # Terminal emulator (fallback, Alacritty is primary)
    foot
    
    # PDF viewer (fallback, Okular is primary)
    evince
  ];
  
  ################################################################################
  # Program-specific Configurations
  ################################################################################
  
  # Git - Version control
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
    };
  };
  
  # GnuPG - Encryption and signing
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  
  # SSH
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };
  
  ################################################################################
  # D-Bus Configuration
  ################################################################################
  services.dbus = {
    enable = true;
    packages = [ pkgs.dconf ];
  };
  
  ################################################################################
  # GVFS - Virtual filesystem support (for Thunar and other file managers)
  ################################################################################
  services.gvfs.enable = true;
  
  ################################################################################
  # Udisks2 - Disk management service
  ################################################################################
  services.udisks2.enable = true;
  
  ################################################################################
  # Firmware Updates
  ################################################################################
  services.fwupd.enable = true;
  
  ################################################################################
  # Automatic System Upgrades (disabled by default, manual control preferred)
  ################################################################################
  system.autoUpgrade = {
    enable = false;  # Manual updates preferred for stability
    flake = "/etc/nixos";
    allowReboot = false;
  };
  
  ################################################################################
  # Documentation
  ################################################################################
  documentation = {
    enable = true;
    man.enable = true;
    dev.enable = true;
  };
}