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