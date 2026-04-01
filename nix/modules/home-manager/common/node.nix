{ pkgs, config, ... }:
{
  home.file = {
    # "${config.home.homeDirectory}/.npmrc".text = ''
    #   prefix=~/.config/npm-global
    # '';

    "${config.home.homeDirectory}/node_modules" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/npm-global/lib/node_modules";
    };
  };
}
