{ config, username, pkgs, ... }:
{
  home = {
    inherit username;
    stateVersion = "24.05";
    homeDirectory = "/Users/${username}";
    sessionPath = [
      "$HOME/bin"
      "$HOME/system/bin"  # Dotfile management scripts
    ];
    sessionVariables = {
      EDITOR = "nvim";
    };
    shellAliases = {
      "switch!" = "~/system/nix/rebuild.sh";
    };
  };

  programs.home-manager.enable = true;
  home.packages = [
    config.nix.package
    pkgs.comic-mono
    pkgs.nixpkgs-fmt
    pkgs.fh
    pkgs.git-agecrypt
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.noto
    pkgs.nerd-fonts._0xproto
    pkgs.tree
  ];

}
