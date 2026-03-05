{ pkgs, lib, ... }:
let
  commonGitConfig = import ../../../modules/home-manager/common/git.nix;
in
{
  home.packages = [
    pkgs.gh
  ];

  programs.lazygit.enable = true;

  programs.git = lib.recursiveUpdate commonGitConfig {
    # No signing - Beyond Identity is macOS-only

    settings = {
      user.name = "Jay Zawrotny";
      user.email = "jay.zawrotny@snowflake.com";

      core = {
        editor = "nvim";
        sshCommand = "/usr/local/bin/sf __ssh";
        excludesFile = "~/.config/git/ignore";
      };

      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
      };

      github = {
        user = "jay-zawrotny_snow";
      };
    };
  };
}
