{ lib, ... }:
with lib;
let
  # Filters out directories that don't end with .nix or are this file, also makes the strings absolute
  indexNixFiles = { ignore, dir }:
    (filter
      (file:
        let
          relPath = lib.removePrefix "./" (lib.path.removePrefix dir file);
        in
        hasSuffix ".nix" file
        && relPath != "default.nix"
        && ! (builtins.elem relPath ignore))
      (filesystem.listFilesRecursive dir));

in
opts: indexNixFiles opts
