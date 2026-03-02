{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../utils/getNixFiles.nix { inherit lib config; };
in
{
  # Personal machine nix-darwin configs
  # Imports common macOS + personal macOS (homebrew, mosh, etc.)
  imports = [
    ./nix.nix
    ../../modules/macOS           # Common macOS configs
    ../../modules/macOS/personal  # Personal homebrew, mosh, etc.
  ] ++ getNixFiles {
    dir = ./.;
    ignore = [ "nix.nix" ];
  };
}
