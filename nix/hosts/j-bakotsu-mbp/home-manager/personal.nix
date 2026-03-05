{ lib, ... }:
let
  getNixFiles = import ../../../lib/getNixFiles.nix { inherit lib; };
in
{
  # Personal machine home configs
  # Imports personal-specific packages (firefox, typst, etc.)
  imports = getNixFiles {
    dir = ../../../modules/home-manager/personal;
    ignore = [ ];
  };
}
