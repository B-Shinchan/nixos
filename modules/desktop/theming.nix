{ config, pkgs, lib, ... }:

{
  ################################################################################
  # System-wide Theming - Dark Mode Default
  ################################################################################

  # GTK Theme configuration
  environment.systemPackages = with pkgs; [
    # GTK themes
    gnome-themes-extra
    adwaita-icon-theme
    papirus-icon-theme
    
    # Qt themes
    adwaita-qt
    adwaita-qt6
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    
    # Theme tools
    lxappearance
    qt5ct
    qt6ct
  ];
  
  # Enable dark theme system-wide
  environment.variables = {
    GTK_THEME = "Adwaita:dark";
    QT_STYLE_OVERRIDE = "adwaita-dark";
  };
  
  # Dark mode for all sessions
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "Adwaita-dark";
        icon-theme = "Papirus-Dark";
        cursor-theme = "Adwaita";
      };
    };
  }];
}