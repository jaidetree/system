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
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];
}
