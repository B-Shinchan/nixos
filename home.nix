{ config, pkgs, inputs, username, ... }:

{
  ################################################################################
  # Home Manager Configuration for User: shinchan
  # Manages user-level configurations, dotfiles, and services
  ################################################################################

  # Home Manager version (must match system stateVersion)
  home.stateVersion = "25.05";
  
  # Home directory
  home.username = username;
  home.homeDirectory = "/home/${username}";
  
  ################################################################################
  # User Packages
  ################################################################################
  home.packages = with pkgs; [
    # Additional user-specific packages
    # Most packages are installed system-wide in modules/applications/
  ];
  
  ################################################################################
  # Niri Compositor Configuration
  ################################################################################
  programs.niri = {
    settings = {
      # Input configuration
      input = {
        keyboard = {
          xkb = {
            layout = "us";  # US keyboard layout
            variant = "";
            options = "";
          };
          
          # Keyboard repeat rate
          repeat-delay = 200;
          repeat-rate = 35;
        };
        
        touchpad = {
          # Touchpad settings (for laptops, won't affect desktops)
          tap = true;
          dwt = true;  # Disable while typing
          natural-scroll = false;  # Traditional scrolling
          accel-speed = 0.0;
          accel-profile = "adaptive";
        };
        
        mouse = {
          natural-scroll = false;
          accel-speed = 0.0;
          accel-profile = "flat";  # No mouse acceleration
        };
        
        # Focus follows mouse
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "10%";
        };
        
        # Tablet settings (if applicable)
        tablet = {
          map-to-output = "eDP-1";
        };
        
        # Disable trackpoint (if present)
        disable-power-key-handling = false;
        warp-mouse-to-focus = false;
        workspace-auto-back-and-forth = false;
      };
      
      # Output (Monitor) configuration
      outputs = {
        "HDMI-A-1" = {
          # Monitor settings for 1920x1080
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.0;
          };
          
          position = { x = 0; y = 0; };
          scale = 1.0;
          transform = "normal";
        };
      };
      
      # Layout configuration
      layout = {
        gaps = 8;  # Gap between windows in pixels
        center-focused-column = "never";
        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];
        default-column-width = { proportion = 0.5; };
        focus-ring = {
          enable = true;
          width = 2;
          active-color = "#7fc8ff";  # Blue focus ring
          inactive-color = "#505050";  # Gray inactive
        };
        
        border = {
          enable = true;
          width = 2;
          active-color = "#7fc8ff";
          inactive-color = "#505050";
        };
        
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
      };
      
      # Window rules
      window-rules = [
        {
          # Default rule for all windows
          matches = [{ }];
          
          # Rounded corners (14px radius)
          geometry-corner-radius = 14.0;
          clip-to-geometry = true;
          
          # Opacity (0.92 for subtle transparency)
          opacity = 0.92;
          
          # Disable client-side decorations
          draw-border-with-background = false;
        }
        
        # Terminal windows (full opacity)
        {
          matches = [{ app-id = "^Alacritty$"; }];
          opacity = 1.0;
        }
        
        # Firefox (full opacity)
        {
          matches = [{ app-id = "^firefox$"; }];
          opacity = 1.0;
        }
        
        # VS Code (full opacity)
        {
          matches = [{ title = "Visual Studio Code"; }];
          opacity = 1.0;
        }
      ];
      
      # Spawn programs at startup
      spawn-at-startup = [
        # Start waybar
        { command = [ "${pkgs.waybar}/bin/waybar" ]; }
        
        # Start clipboard manager
        { command = [ "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${pkgs.cliphist}/bin/cliphist" "store" ]; }
      ];
      
      # Keybindings
      binds = with config.lib.niri.actions; {
        # Mod key is Super (Windows key)
        "Mod+T".action = { spawn = [ "${pkgs.alacritty}/bin/alacritty" ]; };
        "Mod+D".action = { spawn = [ "${pkgs.fuzzel}/bin/fuzzel" ]; };
        "Mod+Q".action = { close-window = { }; };
        
        # Exit Niri
        "Mod+Shift+E".action = { quit = { skip-confirmation = false; }; };
        
        # Focus management
        "Mod+H".action = { focus-column-left = { }; };
        "Mod+L".action = { focus-column-right = { }; };
        "Mod+J".action = { focus-window-down = { }; };
        "Mod+K".action = { focus-window-up = { }; };
        
        # Window movement
        "Mod+Shift+H".action = { move-column-left = { }; };
        "Mod+Shift+L".action = { move-column-right = { }; };
        "Mod+Shift+J".action = { move-window-down = { }; };
        "Mod+Shift+K".action = { move-window-up = { }; };
        
        # Fullscreen
        "Mod+F".action = { fullscreen-window = { }; };
        
        # Overview mode
        "Mod+O".action = { toggle-overview = { }; };
        
        # Workspace switching
        "Mod+1".action = { focus-workspace = 1; };
        "Mod+2".action = { focus-workspace = 2; };
        "Mod+3".action = { focus-workspace = 3; };
        "Mod+4".action = { focus-workspace = 4; };
        "Mod+5".action = { focus-workspace = 5; };
        
        # Move window to workspace
        "Mod+Shift+1".action = { move-window-to-workspace = 1; };
        "Mod+Shift+2".action = { move-window-to-workspace = 2; };
        "Mod+Shift+3".action = { move-window-to-workspace = 3; };
        "Mod+Shift+4".action = { move-window-to-workspace = 4; };
        "Mod+Shift+5".action = { move-window-to-workspace = 5; };
        
        # Screenshots
        "Mod+S".action = { spawn = [ "${pkgs.grim}/bin/grim" "-g" "$(${pkgs.slurp}/bin/slurp)" "$(xdg-user-dir PICTURES)/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png" ]; };
        "Print".action = { spawn = [ "${pkgs.grim}/bin/grim" "$(xdg-user-dir PICTURES)/Screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png" ]; };
        
        # Screen recording
        "Mod+R".action = { spawn = [ "${pkgs.wf-recorder}/bin/wf-recorder" "-f" "$(xdg-user-dir VIDEOS)/recording-$(date +%Y%m%d-%H%M%S).mp4" ]; };
        
        # Lock screen
        "Mod+Escape".action = { spawn = [ "${pkgs.swaylock-effects}/bin/swaylock" "-f" ]; };
      };
      
      # Cursor configuration
      cursor = {
        theme = "Adwaita";
        size = 24;
      };
      
      # Screenshot path
      screenshot-path = "~/Pictures/Screenshots/screenshot-%Y-%m-%d-%H-%M-%S.png";
      
      # Prefer no CSD (client-side decorations)
      prefer-no-csd = true;
      
      # Hotkey overlay
      hotkey-overlay.skip-at-startup = false;
    };
  };
  
  ################################################################################
  # Alacritty Terminal Configuration
  ################################################################################
  programs.alacritty = {
    enable = true;
    
    settings = {
      # Window settings
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        opacity = 0.95;
        decorations = "full";
        startup_mode = "Windowed";
        title = "Alacritty";
        dynamic_title = true;
        class = {
          instance = "Alacritty";
          general = "Alacritty";
        };
      };
      
      # Scrolling
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      
      # Font configuration (CaskaydiaMono Nerd Font)
      font = {
        normal = {
          family = "CaskaydiaCove Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "CaskaydiaCove Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "CaskaydiaCove Nerd Font";
          style = "Italic";
        };
        size = 11.0;
      };
      
      # Colors (Tokyo Night theme)
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
      };
      
      # Cursor
      cursor = {
        style = {
          shape = "Block";
          blinking = "On";
        };
        blink_interval = 750;
      };
      
      # Shell
      shell = {
        program = "${pkgs.fish}/bin/fish";
        args = [ "--login" ];
      };
    };
  };
  
  ################################################################################
  # Fish Shell Configuration
  ################################################################################
  programs.fish = {
    enable = true;
    
    shellInit = ''
      # Disable greeting
      set fish_greeting
      
      # Run fastfetch on shell startup
      if status is-interactive
        ${pkgs.fastfetch}/bin/fastfetch
      end
    '';
    
    shellAliases = {
      # System management
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#NixOS";
      update = "sudo nix flake update /etc/nixos && rebuild";
      clean = "sudo nix-collect-garbage --delete-older-than 15d";
      
      # Modern replacements
      ls = "${pkgs.eza}/bin/eza --icons --group-directories-first";
      ll = "${pkgs.eza}/bin/eza -l --icons --group-directories-first";
      la = "${pkgs.eza}/bin/eza -la --icons --group-directories-first";
      tree = "${pkgs.eza}/bin/eza --tree --icons";
      cat = "${pkgs.bat}/bin/bat --style=plain";
      
      # Git shortcuts
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      
      # Directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      
      # Safety nets
      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -i";
    };
    
    plugins = [
      # Fisher plugin manager
      {
        name = "fisher";
        src = pkgs.fetchFromGitHub {
          owner = "jorgebucaran";
          repo = "fisher";
          rev = "4.4.5";
          sha256 = "sha256-1ZXJx6lL8EZ7SvYlLWfk5UiqR9LyYaX9xxUkb18sVtY=";
        };
      }
    ];
  };
  
  ################################################################################
  # Starship Prompt
  ################################################################################
  programs.starship = {
    enable = true;
    
    settings = {
      format = "$username$hostname$directory$git_branch$git_status$python$nodejs$rust$package$cmd_duration$line_break$character";
      
      username = {
        show_always = true;
        style_user = "bold blue";
        format = "[$user]($style)";
      };
      
      hostname = {
        ssh_only = false;
        format = "[@$hostname](bold green) ";
      };
      
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
      };
      
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      
      git_status = {
        style = "bold yellow";
      };
      
      python = {
        symbol = " ";
        style = "yellow";
      };
      
      nodejs = {
        symbol = " ";
        style = "green";
      };
      
      rust = {
        symbol = " ";
        style = "red";
      };
      
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
  
  ################################################################################
  # Additional CLI Tools
  ################################################################################
  programs.zoxide.enable = true;  # Smart cd
  programs.fzf.enable = true;     # Fuzzy finder
  programs.bat.enable = true;     # Better cat
  programs.eza.enable = true;     # Better ls
  programs.btop.enable = true;    # System monitor
  
  ################################################################################
  # Git Configuration
  ################################################################################
  programs.git = {
    enable = true;
    userName = "shinchan";
    userEmail = "your-email@example.com";  # Change this
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "nvim";
    };
  };
  
  ################################################################################
  # Environment Variables
  ################################################################################
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "brave";
  };
  
  ################################################################################
  # XDG User Directories
  ################################################################################
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
  };
  
  ################################################################################
  # GTK Theme
  ################################################################################
  gtk = {
    enable = true;
    
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    
    font = {
      name = "CaskaydiaCove Nerd Font";
      size = 11;
    };
    
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
  
  ################################################################################
  # Qt Theme
  ################################################################################
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
  
  ################################################################################
  # Home Manager Configuration
  ################################################################################
  programs.home-manager.enable = true;
}