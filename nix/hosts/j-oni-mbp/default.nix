{ self, nixpkgs, home-manager, nix-darwin, ... } @ inputs:
let
  username = "j";
  hostname = "j-oni-mbp";
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
    pkgs = pkgs;
    system = system;
    modules = [
      ./nix-darwin
      home-manager.darwinModules.home-manager
      {
        home-manager.extraSpecialArgs = { inherit inputs username home-manager system; };
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.verbose = true;
        home-manager.users.${username} = import ../../home;
      }
    ];
  };
}
