{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.ngrok
  ];

  home.file = {
    "${config.home.homeDirectory}/Library/Application Support/ngrok/ngrok.yml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/nix/secrets/ngrok.yml";
    };
  };
}
