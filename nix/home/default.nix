{ lib, hostname, ... }:
let
  getNixFiles = import ../utils/getNixFiles.nix { inherit lib; };
in
{
  # Imports common home-manager configs shared by all machines
  # Host-specific configs (including personal/) imported by host's home/default.nix
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
