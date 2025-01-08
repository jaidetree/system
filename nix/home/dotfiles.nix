{ pkgs, config, lib, ... }:
{
  home.file = {
    # ".simple-example".text = "# A simple example";
    # ".multiline-example".text = ''
    #   # A multiline example
    #   # on multiple lines
    # '';
    "${config.home.homeDirectory}/.ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/CloudStorage/Dropbox/Sync/ssh/config";
    };
    "/Library/Keyboard Layouts/Colemak DH.bundle" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/vendor/Colemak DH.bundle";
    };
  };
  home.activation.copyKeyboardLayout = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    ${pkgs.zsh}/bin/zsh -c "sudo cp -r ~/.config/vendor/Colemak\ DH.bundle /Library/Keyboard\ Layouts/"
  '';

}
