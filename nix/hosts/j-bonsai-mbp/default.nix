{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../utils/getNixFiles.nix { inherit lib config; };
in
{
  imports = [
    ./nix.nix
    ../modules/homebrew.nix
    ../modules/mosh.nix
    ../modules/system-prefs.nix
  ] ++ getNixFiles {
    dir = ./.;
    ignore = [ "nix.nix" ];
  };
}
