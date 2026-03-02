{ config, pkgs, lib, ... }:
let
  getNixFiles = import ../../../utils/getNixFiles.nix { inherit lib config; };
in
{
  # Work machine nix-darwin configs
  # Imports common macOS only (no personal homebrew/mosh)
  imports = [
    ./nix.nix
    ./homebrew.nix              # Work-specific homebrew (Snowflake tools)
    ../../modules/macOS         # Common macOS configs only
  ] ++ getNixFiles {
    dir = ./.;
    ignore = [ "nix.nix" "homebrew.nix" ];
  };
}
