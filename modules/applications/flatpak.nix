{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Flatpak Configuration
  # Browsers, communication apps, and OBS Studio
  ################################################################################

  # Enable Flatpak
  services.flatpak.enable = true;
  
  # Enable Flathub repository
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
  
  # Install XDG desktop portals for Flatpak
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
  
  # Note: Flatpak applications are installed via command line:
  # 
  # flatpak install flathub com.brave.Browser
  # flatpak install flathub org.mozilla.firefox
  # flatpak install flathub com.google.Chrome
  # flatpak install flathub org.telegram.desktop
  # flatpak install flathub org.signal.Signal
  # flatpak install flathub com.obsproject.Studio  # OBS Studio
  # flatpak install flathub org.gnome.Boxes  # Gnome Boxes for VMs
  
  environment.systemPackages = with pkgs; [
    # Flatpak management tools
    flatpak
    
    # GNOME Software (Flatpak GUI)
    gnome-software
  ];
}