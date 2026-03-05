{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;

    # Force every new fish session to start a zelli-j session
    enableFishIntegration = false;
    enableZshIntegration = false;
  };
}
