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

    detectbg = { url = "github:will/detectbg"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs @ { self, nixpkgs, nix-darwin, ... }:
    let
      lib = nixpkgs.lib;
      # Import a sequence of hosts and recursively merge their outputs
      importHosts = hosts: (lib.pipe hosts [
        (map (host: (import host inputs)))
        (lib.foldl
          (mainAttrs: hostAttrs:
            (lib.recursiveUpdate mainAttrs hostAttrs))
          { })
      ]);
    in
    # Uncomment if more root config is needed
      # { } //
    (importHosts [
      ./hosts/j-bonsai-mbp
    ]);
}
