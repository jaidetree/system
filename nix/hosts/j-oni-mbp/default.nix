{ self, nixpkgs, home-manager, nix-darwin, hostname, ... } @ inputs:
let
  username = "j";
  system = "aarch64-darwin";
  supportedSystems = [ system ];
  forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  legacyPackages = forAllSystems (system: import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  });
  pkgs = legacyPackages.${system};
in
{
  devShells.${system}.default = pkgs.mkShell {
    packages = [
      (pkgs.writeScriptBin "drswitch" "darwin-rebuild switch --flake .")
      (pkgs.writeScriptBin "hmdiff" "nix profile diff-closures --profile
      ~/.local/state/nix/profiles/home-manager")
    ];
  };

  darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
    inherit pkgs;
    specialArgs = { inherit hostname username; };
    modules = [
      ./nix-darwin
      home-manager.darwinModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs username hostname home-manager system; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.verbose = true;
        home-manager.users.${username} = import ../../home;
      }
    ];
  };
}
