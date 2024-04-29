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
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    shells = [ pkgs.fish ];
  };
}
