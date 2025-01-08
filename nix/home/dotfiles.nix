{ pkgs, config, lib, ... }:
{
  home.file = {
    # ".simple-example".text = "# A simple example";
    # ".multiline-example".text = ''
    #   # A multiline example
    #   # on multiple lines
    # '';
    "${config.home.homeDirectory}/.ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "~/Library/CloudStorage/Dropbox/Sync/ssh/config";
    };

  };
}
