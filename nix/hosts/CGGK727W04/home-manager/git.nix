{ pkgs, lib, ... }:
let
  commonGitConfig = import ../../../modules/home-manager/common/git.nix;
in
{
  home.packages = [
    pkgs.gh
    pkgs.git-secrets
  ];

  programs.lazygit.enable = true;

  programs.git = lib.recursiveUpdate commonGitConfig.base {
    # Work (default) configuration
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

    # Conditional includes for personal repos
    includes = [
      # Add more conditional includes for other personal repo directories as needed
      {
        condition = "gitdir:~/system/";
        contents = lib.recursiveUpdate commonGitConfig.personal commonGitConfig.personalSshCommand;
      }
      {
        condition = "gitdir:~/Documents/Obsidian/personal/";
        contents = lib.recursiveUpdate commonGitConfig.personal commonGitConfig.personalSshCommand;
      }
      {
        condition = "gitdir:~/projects/personal";
        contents = lib.recursiveUpdate commonGitConfig.personal commonGitConfig.personalSshCommand;
      }
    ];
  };
}
