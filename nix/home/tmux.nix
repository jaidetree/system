{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    terminal = "xterm";
    customPaneNavigationAndResize = true;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.fish}/bin/fish";
    extraConfig = ''
    # For some reason default-command is set to zsh, would rather it just use default-shell
    set -g -u default-command
    '';
    plugins = with pkgs.tmuxPackages; [
    ];
  };
}
