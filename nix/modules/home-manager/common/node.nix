{ pkgs, config, lib, ... }:
{
  home.packages = [
    pkgs.ngrok
  ];

  home.file = {
    /* "${config.home.homeDirectory}/.ngrok2/ngrok.yml".text = lib.generators.toYAML {} {
      console_ui_color = "transparent";
    }; */

    "${config.home.homeDirectory}/Library/Application Support/ngrok/ngrok.yml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix/secrets/ngrok.yml";
    };

    "${config.home.homeDirectory}/.npmrc".text = ''
      prefix=~/.config/npm-global
    '';

    "${config.home.homeDirectory}/node_modules" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/npm-global/lib/node_modules";
    };
  };
}
