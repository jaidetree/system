{ pkgs, ... }:
{
  home.packages = [
    pkgs.neovide
    pkgs.neovim
    pkgs.vim
  ];
}
