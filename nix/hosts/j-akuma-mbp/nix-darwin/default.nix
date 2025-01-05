{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../utils/getNixFiles.nix { inherit lib config; };
in
{
  imports = [
    ./nix.nix
    ../../modules/macOS
  ] ++ getNixFiles {
    dir = ./.;
    ignore = [ "nix.nix" ];
  };
}
