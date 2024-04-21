{ config, username, pkgs, ... }:
{
  home = {
    inherit username;
    stateVersion = "24.05";
    homeDirectory = "/Users/${username}";
    sessionPath = [
      "$HOME/bin"
    ];
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
    pkgs.git-agecrypt
    (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
    pkgs.tree
  ];

}
