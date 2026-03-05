{ lib, hostname, ... }:
let
  getNixFiles = import ../lib/getNixFiles.nix { inherit lib; };
in
{
  # Imports common home-manager configs shared by all machines
  # Host-specific configs (including personal/) are in each host's home-manager/ directory
  imports =
    getNixFiles {
      dir = ../modules/home-manager/common;
      ignore = [ "git.nix" ];  # git.nix is a config object, not a module - imported by host-specific configs
    }
    ++ getNixFiles {
      dir = ../hosts/${hostname}/home-manager;
      ignore = [ ];
    };
}
