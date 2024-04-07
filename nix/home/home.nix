{ config, pkgs, ... }:
{
  home = {
    stateVersion = "24.05";
    username = "j";
    homeDirectory = "/Users/j";
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = {
      "switch!" = "darwin-rebuild switch --flake ~/.config/nix";
    };
  };

  programs.home-manager.enable = true;
  home.packages = [
    config.nix.package
    pkgs.nixpkgs-fmt
    pkgs.fh
    pkgs.nodePackages.cspell
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  home.file."${config.home.homeDirectory}/cspell.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/cspell.json";
  };
  
}
