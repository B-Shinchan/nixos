{ config, pkgs, lib, ... }:

{
  ################################################################################
  # System Fonts Configuration
  # CaskaydiaMono Nerd Font, Cascadia Code, JetBrains Mono
  ################################################################################

  fonts = {
    # Enable fonts
    enableDefaultPackages = true;
    
    # Font packages
    packages = with pkgs; [
      # Nerd Fonts (includes CaskaydiaMono)
      (nerdfonts.override {
        fonts = [
          "CascadiaCode"  # CaskaydiaMono is part of this
          "JetBrainsMono"
          "FiraCode"
          "Hack"
          "SourceCodePro"
        ];
      })
      
      # Microsoft Cascadia Code
      cascadia-code
      
      # Additional quality fonts
      liberation_ttf
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      dejavu_fonts
      ubuntu_font_family
      inter
      roboto
      
      # Font tools
      font-manager
    ];
    
    # Font configuration
    fontconfig = {
      enable = true;
      
      # Default fonts
      defaultFonts = {
        serif = [ "Noto Serif" "DejaVu Serif" ];
        sansSerif = [ "Inter" "Noto Sans" "DejaVu Sans" ];
        monospace = [ "CaskaydiaCove Nerd Font" "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
      
      # Subpixel rendering
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      
      # Hinting
      hinting = {
        enable = true;
        autohint = false;
        style = "slight";
      };
      
      # Antialiasing
      antialias = true;
      
      # Font cache
      cache32Bit = true;
    };
  };
}