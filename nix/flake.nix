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
      # Extracts hostname from directory path and passes it to each host config
      importHosts = hosts: (lib.pipe hosts [
        (map (hostPath:
          let
            hostname = lib.last (lib.splitString "/" (toString hostPath));
          in
          (import hostPath (inputs // { inherit hostname; }))
        ))
        (lib.foldl
          (mainAttrs: hostAttrs:
            (lib.recursiveUpdate mainAttrs hostAttrs))
          { })
      ]);
    in
    # Uncomment if more root config is needed
      # { } //
    (importHosts [
      ./hosts/CGGK727W04
      ./hosts/j-akuma-mbp
      ./hosts/j-bakotsu-mbp
      ./hosts/j-oni-mbp
    ]);
}
