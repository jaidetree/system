{
  description = "My system configuration";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    oblique = { url = "github:will/oblique"; inputs.nixpkgs.follows = "nixpkgs"; };
    detectbg = { url = "github:will/detectbg"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, home-manager, nix-darwin, ... }@inputs:
    let
      username = "j";
      system = "aarch64-darwin";
      hostname = "j-bonsai-mbp";
      supportedSystems = [ system ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      legacyPackages = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
      pkgs = legacyPackages.${system};

      mylib = {
        versionCheck = cutoff: pkg:
          let pkgVer = pkgs.${pkg}.version; in
          if 1 == builtins.compareVersions pkgVer cutoff
          then throw "nixpkgs has newer version of ${pkg} (${pkgVer}) than cutoff (${cutoff}). Go back to nixpkgs."
          else inputs.${pkg}.packages.${pkgs.system}.default;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          (pkgs.writeScriptBin "drswitch" "darwin-rebuild switch --flake .")
          (pkgs.writeScriptBin "hmdiff" "nix profile diff-closures --profile ~/.local/state/nix/profiles/home-manager")
        ];
      };

      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        pkgs = pkgs;
        system = system;
        modules = [
          ./hosts/${hostname}
          home-manager.darwinModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs username home-manager mylib; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.verbose = true;
            home-manager.users.${username} = import ./home;
          }
        ];
      };
    };
}
