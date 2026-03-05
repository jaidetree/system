{ lib, config, username, pkgs, ... }:
{
  home = {
    inherit username;
    stateVersion = lib.mkDefault "24.05";
    homeDirectory = lib.mkDefault "/Users/${username}";
    sessionPath = [
      "$HOME/bin"
      "$HOME/system/bin" # Dotfile management scripts
    ];
    sessionVariables = {
      EDITOR = lib.mkDefault "nvim";
    };
    shellAliases = {
      "switch!" = "~/system/nix/rebuild.sh";
    };
  };

  programs.home-manager.enable = true;
  home.packages = lib.optional (config.nix.package != null) config.nix.package
    ++ [
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
