{config, pkgs, lib, ... }: 
{
  home.packages = [
    pkgs.lua54Packages.fennel
  ];

  /**
   * Thanks to Ruther in the nix discord
   * https://discord.com/channels/568306982717751326/1226709145366040576
   * The before hook was found by them at:
   * https://github.com/nix-community/home-manager/blob/a561ad6ab38578c812cc9af3b04f2cc60ebf48c9/modules/files.nix#L124
   */
  home.activation.cloneSpaceHammer = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary"] ''
    SPACEHAMMER_DIR=$HOME/projects/spacehammer
    if [ ! -d "$SPACEHAMMER_DIR" ]; then
      ${pkgs.zsh}/bin/zsh -c "git clone -b spoonify git@github.com:jaidetree/spacehammer.git $SPACEHAMMER_DIR"
    fi
  '';
  home.activation.createSpoonsDirectory = lib.hm.dag.entryAfter [ "cloneSpaceHammer" ] ''
    run mkdir $VERBOSE_ARG -p ~/.hammerspoon/Spoons 
  '';

  # Refer to configDir ${config.xdg.configHome} or ${config.home.homeDirectory}
  home.file = {
    "${config.home.homeDirectory}/.hammerspoon/init.lua".text = ''
      require("hs.ipc")
      spacehammer = hs.loadSpoon("Spacehammer");
      spacehammer:start();
    '';
    "${config.home.homeDirectory}/projects/spacehammer/spacehammer/paths.lua".text = "return " + lib.generators.toLua {} {
      fennel = "${pkgs.lua54Packages.fennel}/share/lua/5.4/fennel.lua";
      configdir = "${config.xdg.configHome}/spacehammer";
    };
    "${config.home.homeDirectory}/.hammerspoon/Spoons/Spacehammer.spoon" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/projects/spacehammer";
    };
  };

}
