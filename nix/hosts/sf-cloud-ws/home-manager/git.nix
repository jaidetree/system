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

  # SSH config for personal repos
  # Work repos use Snowflake's sf __ssh by default
  # Personal repos (like system repo) use jaide-github host with personal key
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "jaide-github" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed_personal";
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };
    };
  };
}
