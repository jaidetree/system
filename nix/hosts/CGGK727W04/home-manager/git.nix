{ pkgs, ... }:
{
  # macOS-only additions on top of modules/home-manager/work/git.nix
  home.packages = [
    pkgs.git-secrets
  ];

  programs.git.signing = {
    signByDefault = true;
    key = "3195AC4CF81866EA95A5D66C6BF5C081A9500AF1";
    signer = "/Applications/Beyond Identity.app/Contents/MacOS/gpg-bi";
  };
}
