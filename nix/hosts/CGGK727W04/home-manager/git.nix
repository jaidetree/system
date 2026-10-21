{ pkgs, ... }:
{
  # macOS-only additions on top of modules/home-manager/work/git.nix
  home.packages = [
    pkgs.git-secrets
  ];

  programs.git.signing = {
    signByDefault = true;
    format = "ssh";
    key = "~/.ssh/snowflake-ghe.pub";
  };
}
