{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.neovide
    pkgs.lua54Packages.fennel
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      fennel-vim
      lazy-nvim
      parinfer-rust
      vim-nix
      zoxide-vim
      /**
       * {plugin = "some-vim-plugin"
       *  type = "lua"; # or viml, teal, fennel
       *  config = ''
       *    local pkg = require('package')
       *    pkg.setup({})
       *  '';
       */
    ];

    extraConfig = ''
      set autoindent
      set autoread
      set clipboard=unnamedplus
      set expandtab
      set foldmethod=manual
      set nobackup
      set nolazyredraw
      set noswapfile
      set relativenumber
      set shiftwidth=2
      set showmatch
      set showmode
      set smarttab
      set splitbelow
      set splitright
      set tabstop=2
      set textwidth=80
      set updatetime=250
      set termguicolors
      colorscheme catppuccin-mocha
    '';

    extraLuaConfig = ''

      fennel = dofile('${pkgs.lua54Packages.fennel}/share/lua/5.4/fennel.lua');
      _G.fennel = fennel

      config = dofile('${config.home.homeDirectory}/.config/nvim/bootstrap.lua')
    '';
  };

  /**
   * Generate a file that can point to some nix paths. This helps load the nix
   * plugins after lazy.nvim does its thing, which is preventing any other
   * plugins from loading.
   */
  home.file = {
    "/.config/nvim/fnl/j/config/paths.fnl".text = ''
      ;; Generated by nix home/vim.nix
      {:nix-pack-path "${pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs}"}
    '';
  };
}
