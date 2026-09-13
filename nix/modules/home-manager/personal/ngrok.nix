{ pkgs, config, ... }:
{
  home.packages = [
    pkgs.ngrok
  ];

  home.file = {
    "${config.home.homeDirectory}/Library/Application Support/ngrok/ngrok.yml" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/system/nix/secrets/ngrok.yml";
    };
  };
}
