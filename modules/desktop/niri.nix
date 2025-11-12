{ config, pkgs, lib, inputs, username, ... }:

{
  ################################################################################
  # Niri Wayland Compositor Configuration
  # Scrollable-tiling compositor with modern features
  ################################################################################

  ################################################################################
  # Enable Niri Compositor
  ################################################################################
  programs.niri = {
    enable = true;
    package = pkgs.niri;  # Use stable Niri package
  };
  
  ################################################################################
  # Display Manager - greetd with tuigreet (lightweight TUI greeter)
  ################################################################################
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd niri-session";
        user = "greeter";
      };
    };
  };
  
  # Alternative: Use gtkgreet for GUI login (uncomment if preferred)
  # services.greetd.settings.default_session.command = "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -c niri-session";
  
  ################################################################################
  # Wayland Essentials
  ################################################################################
  # XWayland support for X11 applications
  programs.xwayland.enable = true;
  
  # XWayland Satellite for better X11 app integration in Niri
  environment.systemPackages = with pkgs; [
    xwayland-satellite
  ];
  
  # Start xwayland-satellite automatically with Niri
  systemd.user.services.xwayland-satellite = {
    description = "Xwayland outside your Wayland";
    bindsTo = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    requisite = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "notify";
      NotifyAccess = "all";
      ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    
    wantedBy = [ "graphical-session.target" ];
  };
  
  ################################################################################
  # Niri-Specific Packages
  ################################################################################
  environment.systemPackages = with pkgs; [
    # Application launcher
    fuzzel
    
    # Notification daemon
    mako
    
    # Status bar (optional, can use waybar instead)
    waybar
    
    # Clipboard manager
    wl-clipboard
    cliphist
    
    # Screenshot tools
    grim      # Screenshot utility
    slurp     # Screen area selector
    swappy    # Screenshot editor
    
    # Screen recording
    wf-recorder
    
    # Color picker
    hyprpicker
    
    # Screen locker
    swaylock-effects
    
    # Idle management
    swayidle
    
    # Background image setter
    swaybg
    
    # Night light (color temperature adjustment)
    hyprsunset
    
    # Terminal (primary and backup)
    alacritty
    foot
    
    # File manager GUI
    xfce.thunar
    
    # Image viewer
    imv
    
    # PDF viewer
    zathura
    
    # Video player
    mpv
    
    # System info
    fastfetch
    
    # Wayland info tools
    wayland-utils
    wlr-randr
  ];
  
  ################################################################################
  # Niri Configuration (managed via home-manager)
  ################################################################################
  # The actual Niri settings (keybindings, window rules, etc.) are configured
  # in home.nix using home-manager for user-specific customization
  
  ################################################################################
  # Polkit Authentication Agent (KDE)
  ################################################################################
  systemd.user.services.polkit-kde-authentication-agent-1 = {
    description = "Polkit KDE Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = "1";
      TimeoutStopSec = "10";
    };
  };
  
  ################################################################################
  # Notification Daemon - mako
  ################################################################################
  systemd.user.services.mako = {
    description = "Mako notification daemon";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "dbus";
      BusName = "org.freedesktop.Notifications";
      ExecStart = "${pkgs.mako}/bin/mako";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  
  ################################################################################
  # Hyprsunset - Permanent Night Light (4100K)
  ################################################################################
  systemd.user.services.hyprsunset = {
    description = "Hyprsunset night light daemon (permanent 4100K)";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset -t 4100";
      Restart = "always";
      RestartSec = "8";  # Wait 8 seconds before restarting
    };
  };
  
  ################################################################################
  # Idle and Lock Screen Configuration
  ################################################################################
  systemd.user.services.swayidle = {
    description = "Idle manager for Wayland";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 600 '${pkgs.swaylock-effects}/bin/swaylock -f' \
          timeout 900 'niri msg action power-off-monitors' \
          resume 'niri msg action power-on-monitors' \
          before-sleep '${pkgs.swaylock-effects}/bin/swaylock -f'
      '';
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  
  ################################################################################
  # GTK Settings for Niri
  ################################################################################
  # GTK theme settings are in modules/desktop/theming.nix
  
  ################################################################################
  # Environment Variables for Niri
  ################################################################################
  environment.sessionVariables = {
    # Wayland session variables
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "niri";
    XDG_CURRENT_DESKTOP = "niri";
    
    # Qt Wayland support
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    
    # Firefox Wayland
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DBUS_REMOTE = "1";
    
    # Electron/Chromium apps
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    
    # SDL2 Wayland
    SDL_VIDEODRIVER = "wayland";
    
    # Java applications
    _JAVA_AWT_WM_NONREPARENTING = "1";
    
    # Clutter (for GNOME apps)
    CLUTTER_BACKEND = "wayland";
    
    # GDK (GTK) backend
    GDK_BACKEND = "wayland,x11";
  };
  
  ################################################################################
  # D-Bus Session Services
  ################################################################################
  services.dbus.packages = with pkgs; [
    xfce.xfconf
    gnome-keyring
  ];
  
  ################################################################################
  # Portal Configuration
  ################################################################################
  xdg.portal = {
    enable = true;
    
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    
    config = {
      common = {
        default = [ "gtk" ];
      };
      
      niri = {
        default = [ "gtk" "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
    
    configPackages = [ pkgs.niri ];
  };
  
  ################################################################################
  # MIME Type Associations
  ################################################################################
  xdg.mime.enable = true;
  
  # Default applications are set in home-manager (home.nix)
  
  ################################################################################
  # Notes for Niri Configuration
  ################################################################################
  # 
  # Niri Keybindings (default, can be customized in home.nix):
  # - Super+T: Open terminal (Alacritty)
  # - Super+D: Application launcher (fuzzel)
  # - Super+Q: Close window
  # - Super+Shift+E: Exit Niri
  # - Super+H/L: Move focus left/right
  # - Super+J/K: Move focus up/down
  # - Super+Shift+H/L: Move window left/right
  # - Super+F: Toggle fullscreen
  # - Super+O: Overview mode
  # - Super+S: Screenshot
  # - Super+Print: Screenshot screen
  # - Alt+Print: Screenshot window
  # 
  # Customization:
  # - Window rules (opacity, rounded corners) are in home.nix
  # - Keybindings can be customized in home.nix
  # - Outputs (monitor configuration) in home.nix
  # - Workspaces configuration in home.nix
  # 
  # Troubleshooting:
  # - Check Niri logs: journalctl -u display-manager -b
  # - Restart Niri: Super+Shift+E (logout) then login again
  # - Check for errors: niri msg
  # - Validate config: niri validate
  # 
  # Performance:
  # - Niri uses GPU acceleration by default
  # - For AMD Vega 8 (Ryzen 3 3200G), performance should be excellent
  # - VRR (Variable Refresh Rate) supported if monitor supports it
  # 
  # X11 Applications:
  # - Most X11 apps work via XWayland
  # - xwayland-satellite provides better X11 integration
  # - Some legacy apps may have minor issues (use native Wayland apps when possible)
  # 
  ################################################################################
}