{ pkgs, config, ... }: {
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" "j" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      user = "j";
    };
    extraOptions = ''
      warn-dirty = false
      log-lines = 40
      connect-timeout = 5
      min-free = 128000000 # 128mb
      max-free = 1000000000 # 1gb
      builders-use-substitutes = true
    '';
  };
  system.configurationRevision = config.rev or config.dirtyRev or null;
  system.stateVersion = 4;

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowUnfree = true;
  };
}
