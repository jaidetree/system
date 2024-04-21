{ lib, ... }:
let
  getNixFiles = import ../utils/getNixFiles.nix { inherit lib; };
in
{
  # @TODO: Consider adding a build script that throws an error or auto git 
  #        stages the nix files in this directory
  # @NOTE: Additional modules must be at least staged in git.
  imports = [ ./home.nix ] ++ getNixFiles {
    dir = ./.;
    ignore = [ "home.nix" ];
  };
}
