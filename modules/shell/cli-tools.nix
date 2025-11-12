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