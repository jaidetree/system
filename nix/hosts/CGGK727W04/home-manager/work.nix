{ lib, ... }:
let
  getNixFiles = import ../../../lib/getNixFiles.nix { inherit lib; };
in
{
  # Work machine home configs
  # Imports work-specific packages shared with sf-cloud-ws
  imports = getNixFiles {
    dir = ../../../modules/home-manager/work;
    ignore = [ ];
  };
}
