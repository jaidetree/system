{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../lib/getNixFiles.nix { inherit lib config; };
in
{
  # Work machine nix-darwin configs
  # Imports common macOS only (no personal homebrew/mosh)
  imports = [
    ./nix.nix
    ./homebrew.nix              # Work-specific homebrew (Snowflake tools)
    ../../../modules/darwin/common  # Common macOS configs only
  ] ++ getNixFiles {
    dir = ./.;
    ignore = [ "nix.nix" "homebrew.nix" ];
  };
}
