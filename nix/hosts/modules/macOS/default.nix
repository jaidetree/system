{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../utils/getNixFiles.nix { inherit lib config; };
in
{
  # Common macOS configs for all macs
  # Personal macs should additionally import from ./personal/ in their host config
  imports = getNixFiles {
    dir = ./common;
    ignore = [ ];
  };
}
