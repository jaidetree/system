{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;

    # Include sf-cli auto-generated config
    includes = [
      "${config.home.homeDirectory}/.local/share/sfcli/ssh_config"
    ];

    matchBlocks = {
      "jaide-github" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed_personal";
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };
    };
  };

  # LaunchAgent to automatically load SSH key from macOS keychain on login
  launchd.agents.ssh-add-personal = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.openssh}/bin/ssh-add"
        "--apple-use-keychain"
        "${config.home.homeDirectory}/.ssh/id_ed_personal"
      ];
      RunAtLoad = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/ssh-add-personal.err.log";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/ssh-add-personal.out.log";
    };
  };
}
