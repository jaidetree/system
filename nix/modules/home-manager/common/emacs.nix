{ config, lib, pkgs, ... }:
let
  version = "31";
in
{
  # Bootstrap Doom Emacs once, then get out of the way. Nix only clones the
  # framework if it's missing; `doom sync` / `doom upgrade` own all updates
  # thereafter. emacs-plus itself is installed via homebrew.
  home.activation.cloneDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    DOOM_DIR="${config.xdg.configHome}/emacs"
    if [ ! -d "$DOOM_DIR" ]; then
      run ${pkgs.git}/bin/git clone --depth 1 \
        https://github.com/doomemacs/doomemacs "$DOOM_DIR"
      echo "Doom cloned. Run 'doom install' to finish setup."
    fi
  '';

  # Put the `doom` CLI on PATH.
  home.sessionPath = [ "${config.xdg.configHome}/emacs/bin" ];

  # Link the Homebrew-built Emacs.app into /Applications so Spotlight sees it.
  system.activationScripts.applications.text = ''
    if [ -e /opt/homebrew/opt/emacs-plus@${version}/Emacs.app ]; then
      $DRY_RUN_CMD ln -sfn /opt/homebrew/opt/emacs-plus@${version}/Emacs.app /Applications/Emacs.app
    fi
  '';
}
