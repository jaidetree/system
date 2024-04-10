{ pkgs, config, lib, ... }:
{
  home.packages = [
    pkgs.ngrok
    pkgs.nodePackages_latest.prettier
    pkgs.nodePackages_latest.typescript-language-server
    pkgs.nodePackages.cspell
    pkgs.tailwindcss-language-server
  ];

  home.file = {
    /* "${config.home.homeDirectory}/.ngrok2/ngrok.yml".text = lib.generators.toYAML {} {
      console_ui_color = "transparent";
    }; */
    "${config.home.homeDirectory}/Library/Application Support/ngrok/ngrok.yml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix/secrets/ngrok.yml";
    };
    "${config.home.homeDirectory}/cspell.json" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/cspell.json";
    };
  };
  
}
