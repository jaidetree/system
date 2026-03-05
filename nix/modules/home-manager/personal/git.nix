{ pkgs, lib, ... }:
let
  commonGitConfig = import ../shared/git.nix;
in
{
  home.packages = [
    pkgs.gh
  ];

  programs.lazygit.enable = true;

  programs.git = lib.recursiveUpdate commonGitConfig.base {
    signing = {
      signByDefault = true;
      key = "~/.ssh/id_ed25519.pub";
    };

    settings = commonGitConfig.personal;
  };
}
