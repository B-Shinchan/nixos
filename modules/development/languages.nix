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