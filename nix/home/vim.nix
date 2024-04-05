{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovide
    pkgs.vim
    pkgs.lua54Packages.fennel
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      vim-nix
      vim-tmux-navigator
      zoxide-vim
    ];

    extraConfig = ''
      set nobackup
      set relativenumber
      set shiftwidth=2
    '';
  };
}
