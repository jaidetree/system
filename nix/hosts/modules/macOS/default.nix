{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../utils/getNixFiles.nix { inherit lib config; };
in
{
  imports = getNixFiles {
    dir = ./.;
    ignore = [ ];
  };
}
