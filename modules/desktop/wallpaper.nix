{ config, pkgs, lib, username, ... }:

{
  ################################################################################
  # Automatic Wallpaper Changer
  # Changes wallpaper every 3 minutes from ~/Pictures/Wallpapers
  ################################################################################

  # Install swaybg for wallpaper management
  environment.systemPackages = with pkgs; [
    swaybg
  ];
  
  # Wallpaper changer service (runs every 3 minutes)
  systemd.user.services.wallpaper-changer = {
    description = "Random Wallpaper Changer";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.writeShellScript "wallpaper-changer" ''
        #!/usr/bin/env bash
        
        WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
        
        # Create directory if it doesn't exist
        mkdir -p "$WALLPAPER_DIR"
        
        while true; do
          # Find a random wallpaper
          WALLPAPER=$(find "$WALLPAPER_DIR" -type f \
            \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) \
            | shuf -n 1)
          
          # Set wallpaper if found
          if [ -n "$WALLPAPER" ]; then
            ${pkgs.swaybg}/bin/swaybg -i "$WALLPAPER" -m fill &
            
            # Kill previous swaybg instance
            sleep 1
            pkill -o swaybg
          fi
          
          # Wait 3 minutes (180 seconds)
          sleep 180
        done
      ''}";
      Restart = "always";
      RestartSec = "10";
    };
  };
}