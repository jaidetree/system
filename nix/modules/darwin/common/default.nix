{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../lib/getNixFiles.nix { inherit lib config; };
in
{
  imports = getNixFiles {
    dir = ./.;
    ignore = [ ];
  };
}
