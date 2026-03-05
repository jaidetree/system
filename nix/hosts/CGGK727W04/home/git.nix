{ pkgs, lib, ... }:
let
  commonGitConfig = import ../../../home/shared/git.nix;
in
{
  home.packages = [
    pkgs.gh
    pkgs.git-secrets
  ];

  programs.lazygit.enable = true;

  programs.git = lib.recursiveUpdate commonGitConfig {
    signing = {
      signByDefault = true;
      key = "3195AC4CF81866EA95A5D66C6BF5C081A9500AF1";
      signer = "/Applications/Beyond Identity.app/Contents/MacOS/gpg-bi";
    };

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
