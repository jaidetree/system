{ pkgs, ... }:
{
  home.packages = [
    pkgs.typst
    pkgs.typstyle
    pkgs.typst-live
    pkgs.typstwriter
  ];
}
