{
  description = "Build tools for compiling native modules used by Doom packages (e.g. ghostel's Zig module)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = [
              pkgs.zig_0_15 # term/ghostel's native module (M-x ghostel-module-compile)
              pkgs.pkg-config
              pkgs.cmake
              pkgs.gnumake
              pkgs.libtool
            ];
          };
        });
    };
}
