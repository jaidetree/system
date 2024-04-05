{ config, pkgs, inputs, lib, ... }: 
with lib;
let 
  # Recursively constructs an attrset of a given folder, recursing on directories, value of attrs is the filetype
  getDir = dir: mapAttrs (file: type:
    if type == "directory" then getDir "${dir}/${file}" else type
  ) (builtins.readDir dir);

  # Collects all files of a directory as a list of strings of paths
  files = dir: collect isString (mapAttrsRecursive (path: type: concatStringsSep "/" path) (getDir dir));

  # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
  validFiles = dir: 
    map (file: ./. + "/${file}") 
    (filter 
      (file: hasSuffix ".nix" file 
	     && file != "default.nix"
	     && file != "home.nix"
      ) 
      (files dir));

in {
  # @TODO: Consider adding a build script that throws an error or auto git 
  #        stages the nix files in this directory
  # @NOTE: Additional modules must be at least staged in git.
  imports = [ ./home.nix ] ++ validFiles ./.;
}
