{ pkgs, config, ... }: {
  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.direnv.enable = true;

  environment = {
    systemPackages = [
      pkgs.reattach-to-user-namespace
      pkgs.vim
    ];
    systemPath = [
      config.homebrew.brewPrefix
    ];
    shells = [ pkgs.fish ];
  };
}
