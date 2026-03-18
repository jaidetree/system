{ lib, pkgs, username, hostname, ... }:
let
  getNixFiles = import ../../lib/getNixFiles.nix { inherit lib; };
in {
  imports =
    # Import all common home configs
    getNixFiles {
      dir = ../../modules/home-manager/common;
      ignore = [ "spachammer.nix" "git.nix" ];
    }
    # Import cloud-specific home configs
    ++ getNixFiles {
      dir = ./home-manager;
      ignore = [ ];
    };

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";

  home.sessionVariables = {
    EDITOR = "nvim";
    GIT_EDITOR = "nvim";
  };

  # Cloud-specific packages (in addition to common/)
  home.packages = with pkgs; [
    devenv  # Snowflake development
  ];

  # Allow unfree packages (for Snowflake tools)
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;
}