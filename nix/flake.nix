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

  outputs = inputs @ { self, nixpkgs, nix-darwin, ... }:
    let
      system = "aarch64-darwin";
      supportedSystems = [ system ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      legacyPackages = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
      pkgs = legacyPackages.${system};
    in
    { } // import ./hosts/j-bonsai-mbp (inputs // {
      inherit self nixpkgs nix-darwin;
    });
}
