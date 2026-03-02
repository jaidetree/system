{ pkgs, config, ... }: {
  programs.zsh.enable = true;
  programs.fish.enable = true;
  # Installed already through sf setup macos
  # programs.direnv.enable = true;

  environment = {
    systemPackages = [
      pkgs.reattach-to-user-namespace
      pkgs.vim
    ];
    systemPath = [
      config.homebrew.prefix
      "~/.local/bin"
    ];
    shells = [ pkgs.fish ];
  };
}
