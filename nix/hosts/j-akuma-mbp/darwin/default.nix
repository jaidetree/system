{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../lib/getNixFiles.nix { inherit lib config; };
in
{
  # Personal machine nix-darwin configs
  # Imports common macOS + personal macOS (homebrew, mosh, etc.)
  imports = [
    ./nix.nix
    ../../../modules/darwin/common    # Common macOS configs
    ../../../modules/darwin/personal  # Personal homebrew, mosh, etc.
  ] ++ getNixFiles {
    dir = ./.;
    ignore = [ "nix.nix" ];
  };
}
