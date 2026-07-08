{ config, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # Include sf-cli auto-generated config
    includes = [
      "${config.home.homeDirectory}/.local/share/sfcli/ssh_config"
    ];

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };

      "jaide-github" = {
        Hostname = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/id_ed_personal";
        IdentitiesOnly = "yes";
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
      };

      "bakotsu" = {
        Hostname = "100.82.84.15";
        User = "j";
        IdentityFile = "~/.ssh/id_ed_personal";
        IdentitiesOnly = "yes";
        AddKeysToAgent = "yes";
        UseKeychain = "yes";
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
