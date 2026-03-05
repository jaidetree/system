{ lib, ... }:
let
  getNixFiles = import ../../../lib/getNixFiles.nix { inherit lib; };
in
{
  imports = getNixFiles {
    dir = ./.;
    ignore = [ ];
  };
}
