{config, pkgs, lib, ... }: 
{
  home.packages = [
    pkgs.lua54Packages.fennel
  ];

  # Refer to configDir ${config.xdg.configHome}
  home.file = {
    "${config.home.homeDirectory}/.hammerspoon/init.lua".text = ''
      require("hs.ipc")
      spacehammer = hs.loadSpoon("Spacehammer");
      spacehammer.paths.fennel = "${pkgs.lua54Packages.fennel}/share/lua/5.4/fennel.lua";
      spacehammer:start();
    '';
    "${config.home.homeDirectory}/.hammerspoon/Spoons/Spacehammer.spoon" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/spacehammer";
    };
  };

  home.activation.create-spoons-directory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir $VERBOSE_ARG -p ~/.hammerspoon/Spoons 
  '';
}
