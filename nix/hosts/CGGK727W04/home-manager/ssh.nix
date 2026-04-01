{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Include sf-cli auto-generated config
    includes = [
      "${config.home.homeDirectory}/.local/share/sfcli/ssh_config"
    ];

    matchBlocks = {
      # Default SSH settings (explicitly defined to avoid deprecation warning)
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };

      "jaide-github" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed_personal";
        identitiesOnly = true;
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
