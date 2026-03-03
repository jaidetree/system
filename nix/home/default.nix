{ lib, hostname, ... }:
let
  getNixFiles = import ../utils/getNixFiles.nix { inherit lib; };
in
{
  # Imports common home-manager configs shared by all machines
  # Host-specific configs (including personal/) are in each host's home/ directory
  imports =
    getNixFiles {
      dir = ./common;
      ignore = [ ];
    }
    ++ getNixFiles {
      dir = ../hosts/${hostname}/home;
      ignore = [ ];
    };
}
