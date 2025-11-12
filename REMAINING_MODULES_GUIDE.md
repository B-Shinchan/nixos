# Remaining NixOS Configuration Modules

This document provides the complete code for all remaining module files needed to complete your NixOS 25.05 configuration.

---

## File Structure

```
/etc/nixos/
├── modules/
│   ├── desktop/
│   │   ├── fonts.nix
│   │   ├── theming.nix
│   │   └── wallpaper.nix
│   ├── shell/
│   │   └── cli-tools.nix
│   ├── development/
│   │   ├── languages.nix
│   │   ├── editors.nix
│   │   └── ai-ml.nix
│   └── applications/
│       ├── native.nix
│       └── flatpak.nix
```

---

## `modules/desktop/fonts.nix`

```nix
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
```

---

## `modules/desktop/theming.nix`

```nix
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
```

---

## `modules/desktop/wallpaper.nix`

```nix
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
```

---

## `modules/shell/cli-tools.nix`

```nix
{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Modern CLI Tools and Utilities
  ################################################################################

  environment.systemPackages = with pkgs; [
    # Modern replacements for traditional Unix tools
    eza          # Modern ls replacement
    bat          # Better cat with syntax highlighting
    ripgrep      # Fast grep alternative (rg)
    fd           # Fast find alternative
    sd           # Modern sed alternative
    du-dust      # Better du
    duf          # Better df
    procs        # Modern ps
    
    # Fuzzy finder
    fzf
    
    # Smart cd
    zoxide
    
    # System monitoring
    btop         # Beautiful top
    htop         # Interactive process viewer
    iotop        # I/O monitoring
    
    # System information
    fastfetch    # Modern neofetch replacement
    inxi         # Detailed system info
    hwinfo       # Hardware information
    
    # File management
    ranger       # Terminal file manager
    mc           # Midnight Commander
    nnn          # Terminal file manager
    
    # Archive tools
    atool        # Archive tool wrapper
    unrar        # RAR support
    p7zip        # 7-Zip
    unzip        # ZIP support
    zip          # ZIP creation
    
    # Download tools
    wget
    curl
    aria2        # Multi-protocol downloader
    yt-dlp       # YouTube downloader
    
    # Git tools
    gh           # GitHub CLI
    git-lfs      # Git Large File Storage
    lazygit      # Terminal UI for git
    tig          # Text-mode interface for git
    
    # Development utilities
    jq           # JSON processor
    yq-go        # YAML processor
    tmux         # Terminal multiplexer
    zellij       # Modern terminal multiplexer
    direnv       # Directory-specific environment
    
    # Network tools
    bandwhich    # Network bandwidth monitor
    dogdns       # Modern dig
    gping        # Ping with graph
    
    # Disk utilities
    ncdu         # NCurses disk usage
    
    # Text processing
    pandoc       # Universal document converter
    
    # Security tools
    age          # Modern encryption
    pass         # Password manager
    
    # Miscellaneous
    tldr         # Simplified man pages
    tree         # Directory tree viewer
    which        # Show full path of commands
    man-pages    # Linux manual pages
    man-pages-posix
  ];
  
  # Enable command-not-found
  programs.command-not-found.enable = true;
  
  # Enable direnv for per-directory environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

---

## `modules/development/languages.nix`

```nix
{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Programming Languages and Development Tools
  # Python, Node.js, Rust, C/C++, Java, Go
  ################################################################################

  environment.systemPackages = with pkgs; [
    ############################################################################
    # Python Development
    ############################################################################
    python3Full
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.poetry
    python3Packages.pipx
    
    ############################################################################
    # Node.js and JavaScript
    ############################################################################
    nodejs_22        # Latest LTS Node.js
    nodePackages.npm
    nodePackages.yarn
    nodePackages.pnpm
    nodePackages.typescript
    nodePackages.typescript-language-server
    
    ############################################################################
    # Rust
    ############################################################################
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
    
    ############################################################################
    # C/C++ Development
    ############################################################################
    gcc
    clang
    clang-tools
    cmake
    gnumake
    ninja
    meson
    ccache
    
    ############################################################################
    # Go
    ############################################################################
    go
    gopls          # Go language server
    gotools
    go-tools
    
    ############################################################################
    # Java
    ############################################################################
    jdk
    maven
    gradle
    
    ############################################################################
    # Build Tools
    ############################################################################
    pkg-config
    autoconf
    automake
    libtool
    
    ############################################################################
    # Version Control
    ############################################################################
    git
    git-lfs
    gh             # GitHub CLI
    
    ############################################################################
    # Debugging and Profiling
    ############################################################################
    gdb
    valgrind
    strace
    ltrace
    
    ############################################################################
    # Documentation
    ############################################################################
    man-pages
    man-pages-posix
    
    ############################################################################
    # LSP and Language Servers
    ############################################################################
    nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON
    nodePackages.yaml-language-server
    nodePackages.bash-language-server
    marksman       # Markdown language server
  ];
  
  # Enable development tools
  programs.java.enable = true;
}
```

---

## `modules/development/editors.nix`

```nix
{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Text Editors and IDEs
  # Neovim (default) and VS Code
  ################################################################################

  environment.systemPackages = with pkgs; [
    ############################################################################
    # Neovim (Default Editor)
    ############################################################################
    neovim
    
    # Neovim dependencies
    tree-sitter
    ripgrep
    fd
    
    # Neovim LSP support
    nodePackages.neovim
    
    ############################################################################
    # VS Code (Official Microsoft Build)
    ############################################################################
    vscode          # Official Microsoft VS Code
    
    # VS Code extensions (optional, can be installed via VS Code UI)
    # vscode-extensions.ms-python.python
    # vscode-extensions.rust-lang.rust-analyzer
    # vscode-extensions.ms-vscode.cpptools
  ];
  
  # Set Neovim as default editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  
  # Neovim configuration (basic, user can customize)
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    configure = {
      customRC = ''
        " Basic Settings
        set number
        set relativenumber
        set expandtab
        set tabstop=2
        set shiftwidth=2
        set smartindent
        set wrap
        set ignorecase
        set smartcase
        set hlsearch
        set incsearch
        set termguicolors
        set clipboard=unnamedplus
        
        " Leader key
        let mapleader = " "
        
        " Basic keymaps
        nnoremap <leader>w :w<CR>
        nnoremap <leader>q :q<CR>
        nnoremap <leader>e :Ex<CR>
      '';
      
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          # Essential plugins
          nvim-treesitter.withAllGrammars
          telescope-nvim
          plenary-nvim
          
          # LSP
          nvim-lspconfig
          
          # Completion
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          
          # Git
          fugitive
          gitsigns-nvim
          
          # Appearance
          tokyonight-nvim
          lualine-nvim
          nvim-web-devicons
          
          # File explorer
          nvim-tree-lua
          
          # Other utilities
          comment-nvim
          which-key-nvim
        ];
      };
    };
  };
}
```

---

## `modules/development/ai-ml.nix`

```nix
{ config, pkgs, lib, ... }:

{
  ################################################################################
  # AI, Machine Learning, and Data Science Tools
  # Python libraries, Jupyter, and related tools
  ################################################################################

  environment.systemPackages = with pkgs; [
    ############################################################################
    # Python Data Science Libraries
    ############################################################################
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.pandas
    python3Packages.matplotlib
    python3Packages.seaborn
    python3Packages.plotly
    python3Packages.scikit-learn
    python3Packages.scikit-image
    python3Packages.opencv4
    
    ############################################################################
    # Machine Learning Frameworks
    ############################################################################
    python3Packages.tensorflow
    python3Packages.torch
    python3Packages.torchvision
    python3Packages.keras
    
    ############################################################################
    # Jupyter and Notebooks
    ############################################################################
    jupyter
    python3Packages.jupyterlab
    python3Packages.notebook
    python3Packages.ipython
    python3Packages.ipykernel
    
    ############################################################################
    # Data Processing
    ############################################################################
    python3Packages.polars
    python3Packages.pyarrow
    python3Packages.dask
    
    ############################################################################
    # NLP and Text Processing
    ############################################################################
    python3Packages.nltk
    python3Packages.spacy
    python3Packages.transformers
    
    ############################################################################
    # Visualization
    ############################################################################
    python3Packages.pillow
    python3Packages.imageio
    
    ############################################################################
    # Database Connectivity
    ############################################################################
    python3Packages.sqlalchemy
    python3Packages.psycopg2
    python3Packages.pymongo
    
    ############################################################################
    # Scientific Computing
    ############################################################################
    python3Packages.sympy
    python3Packages.statsmodels
    
    ############################################################################
    # Utilities
    ############################################################################
    python3Packages.requests
    python3Packages.beautifulsoup4
    python3Packages.selenium
    python3Packages.pytest
  ];
  
  # CUDA Support (for NVIDIA GPUs - will be activated when GPU is added)
  # nixpkgs.config.cudaSupport = true;
}
```

---

## `modules/applications/native.nix`

```nix
{ config, pkgs, lib, ... }:

{
  ################################################################################
  # Native Applications (installed via Nix)
  ################################################################################

  environment.systemPackages = with pkgs; [
    ############################################################################
    # Productivity
    ############################################################################
    obsidian         # Note-taking
    anki            # Spaced repetition flashcards
    libreoffice-qt6-fresh  # Office suite
    
    ############################################################################
    # Cloud Storage
    ############################################################################
    megasync        # MEGA cloud sync
    
    ############################################################################
    # Geographic Information System
    ############################################################################
    qgis            # Geographic information system
    
    ############################################################################
    # Media
    ############################################################################
    mpv             # Media player (default)
    vlc             # Alternative media player
    kdenlive        # Video editing
    
    ############################################################################
    # Document Viewers
    ############################################################################
    okular          # PDF viewer (default)
    evince          # Alternative PDF viewer
    zathura         # Minimal PDF viewer
    
    ############################################################################
    # Image Viewers/Editors
    ############################################################################
    gwenview        # Image viewer (default)
    gimp            # Image editor
    inkscape        # Vector graphics
    
    ############################################################################
    # Communication
    ############################################################################
    # (Installed via Flatpak)
    
    ############################################################################
    # Utilities
    ############################################################################
    keepassxc       # Password manager
    syncthing       # File synchronization
    
    ############################################################################
    # System Tools
    ############################################################################
    gparted         # Partition editor
    baobab          # Disk usage analyzer
    filelight       # Disk usage visualizer
    
    ############################################################################
    # Mind Mapping (as requested)
    ############################################################################
    freemind        # Mind mapping software
    # Alternative: xmind
  ];
}
```

---

## `modules/applications/flatpak.nix`

```nix
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
```

---

## Hardware Configuration Note

The `hardware-configuration.nix` file is **auto-generated** during installation by `nixos-generate-config`. 

After running the install script, you'll need to edit `/mnt/etc/nixos/hardware-configuration.nix` to ensure the LUKS configuration is correct. Look for the `boot.initrd.luks.devices` section and verify it matches your encryption setup.

---

## Installation Steps

1. **Run the install script** (already provided as `install.sh`)
2. **Copy all configuration files** to `/mnt/etc/nixos/`
3. **Edit `/mnt/etc/nixos/hardware-configuration.nix`** to add any missing LUKS/BTRFS mount options
4. **Run installation**:
   ```bash
   sudo nixos-install --flake /mnt/etc/nixos#NixOS
   ```
5. **Set user password** when prompted
6. **Reboot** and enjoy your system!

---

## Post-Installation

After first boot:

1. Install Flatpak apps:
   ```bash
   flatpak install flathub com.brave.Browser
   flatpak install flathub org.mozilla.firefox
   flatpak install flathub com.google.Chrome
   flatpak install flathub org.telegram.desktop
   flatpak install flathub org.signal.Signal
   flatpak install flathub com.obsproject.Studio
   flatpak install flathub org.gnome.Boxes
   ```

2. Set default browser:
   ```bash
   xdg-settings set default-web-browser com.brave.Browser.desktop
   ```

3. Configure Git:
   ```bash
   git config --global user.name "shinchan"
   git config --global user.email "your-email@example.com"
   ```

4. Add wallpapers:
   ```bash
   mkdir -p ~/Pictures/Wallpapers
   # Copy your favorite wallpapers there
   ```

5. Customize Neovim (optional):
   - Edit `~/.config/nvim/init.lua` or `~/.config/nvim/init.vim`

---

## Troubleshooting

### WiFi Issues
```bash
# Check iwd status
sudo systemctl status iwd

# Restart networking
sudo systemctl restart NetworkManager iwd

# Scan for networks
iwctl station wlan0 scan
iwctl station wlan0 get-networks
```

### Display Issues
```bash
# Check Niri logs
journalctl -u display-manager -b

# Restart display manager
sudo systemctl restart display-manager
```

### Update System
```bash
# Update flake inputs
sudo nix flake update /etc/nixos

# Rebuild system
sudo nixos-rebuild switch --flake /etc/nixos#NixOS
```

---

## All Done!

Your NixOS 25.05 "Warbler" system is now complete with:
- ✅ Niri Wayland compositor
- ✅ Full disk encryption
- ✅ Beautiful terminal and shell
- ✅ Complete development environment
- ✅ All requested applications
- ✅ Hardened security
- ✅ Optimized performance

**Enjoy your new NixOS system!** 🎉