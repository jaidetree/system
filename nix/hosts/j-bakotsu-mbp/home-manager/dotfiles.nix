{ pkgs, config, lib, ... }:
{
  # Note: Dotfiles are managed by `dot link` (called by rebuild.sh), which
  # materializes the hosts/<hostname>/ $HOME-mirror manifest into $HOME
  # This file only contains special-case symlinks that don't fit the standard pattern

  home.file = {
    # SSH config from Dropbox sync
    "${config.home.homeDirectory}/.ssh/config" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/CloudStorage/Dropbox/Sync/ssh/config";
    };

    # Keyboard layout (needs to be in /Library)
    "/Library/Keyboard Layouts/Colemak DH.bundle" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/vendor/Colemak DH.bundle";
    };
  };
  home.activation.copyKeyboardLayout = lib.hm.dag.entryBetween [ "linkGeneration" ] [ "writeBoundary" ] ''
    ${pkgs.zsh}/bin/zsh -c "sudo cp -r ~/system/vendor/Colemak\ DH.bundle /Library/Keyboard\ Layouts/"
  '';

}
