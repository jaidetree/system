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

  outputs = inputs @ { self, nixpkgs, nix-darwin, home-manager, ... }:
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

      # Create home-manager config for cloud workspace
      mkHomeConfig = { system, username, hostname }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit username hostname; };
          modules = [ ./hosts/${hostname} ];
        };
    in
    # Darwin configurations for macOS hosts
    (importHosts [
      ./hosts/CGGK727W04
      ./hosts/j-akuma-mbp
      ./hosts/j-bakotsu-mbp
      ./hosts/j-oni-mbp
    ])
    # Home-manager configurations for Linux cloud workspaces
    // {
      homeConfigurations = {
        "jzawrotny-sf-cloud-ws" = mkHomeConfig {
          system = "x86_64-linux";
          username = "jzawrotny";
          hostname = "sf-cloud-ws";
        };
      };
    };
}
