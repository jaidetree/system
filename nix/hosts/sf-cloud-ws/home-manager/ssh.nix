{ ... }:
{
  # SSH config for personal repos
  # Work repos use Snowflake's sf __ssh by default (configured in git.nix)
  # Personal repos (like system repo) use jaide-github host with personal key
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      # Default SSH settings (explicitly defined to avoid deprecation warning)
      "*" = {
        identityFile = [
          "~/.ssh/id_rsa"
          "~/.ssh/id_dsa"
          "~/.ssh/id_ecdsa"
          "~/.ssh/id_ed25519"
          "~/.ssh/id_ecdsa_sk"
          "~/.ssh/id_ed25519_sk"
        ];
        extraOptions = {
          AddKeysToAgent = "yes";
        };
      };

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
