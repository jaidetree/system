{ lib, ... }:
let
  getNixFiles = import ../../../../utils/getNixFiles.nix { inherit lib; };
in
{
  # Personal machine home configs
  # Imports personal-specific packages (firefox, typst, etc.)
  imports = getNixFiles {
    dir = ../../../home/personal;
    ignore = [ ];
  };
}
