{ pkgs, lib, ... }:
let
  commonGitConfig = import ../shared/git.nix;
in
{
  home.packages = [
    pkgs.gh
  ];

  programs.lazygit.enable = true;

  programs.git = lib.recursiveUpdate commonGitConfig {
    signing = {
      signByDefault = true;
      key = "/Users/j/.ssh/id_ed25519.pub";
    };

    settings = {
      user.name = "jaide";
      user.email = "jayzawrotny@gmail.com";

      github = {
        user = "jaidetree";
      };

      gpg.format = "ssh";
    };
  };
}
