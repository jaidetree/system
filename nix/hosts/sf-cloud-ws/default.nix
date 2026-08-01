{ lib, pkgs, username, hostname, ... }:
let
  getNixFiles = import ../../lib/getNixFiles.nix { inherit lib; };
in
{
  imports =
    # Import all common home configs
    getNixFiles
      {
        dir = ../../modules/home-manager/common;
        ignore = [ "spacehammer.nix" "git.nix" ];
      }
    # Import work-specific home configs (shared with CGGK727W04)
    ++ getNixFiles {
      dir = ../../modules/home-manager/work;
      ignore = [ ];
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
    devenv # Snowflake development
  ];

  # Allow unfree packages (for Snowflake tools)
  nixpkgs.config.allowUnfree = true;

  # HM 26.05 + nixpkgs 26.11 version skew is intentional
  home.enableNixpkgsReleaseCheck = false;

  programs.home-manager.enable = true;
}

