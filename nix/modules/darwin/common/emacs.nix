{ pkgs, lib, ... }:
let
  emacsPlus = {
    name = "emacs-plus@31";
    args = [
      "with-dbus"
      "with-imagemagick"
      "with-mailutils"
      "with-xwidgets"
    ];
  };
in
{
  homebrew = {
    enable = true;
    taps = [
      {
        name = "d12frosted/emacs-plus";
        trusted = true;
      }
    ];
    brews = [ emacsPlus ];
  };

  # Copy the Homebrew-built Emacs.app into /Applications so Spotlight can find it.
  # emacs-plus is a formula (not a cask), so Homebrew won't place the .app bundle
  # in /Applications on its own. We re-copy on every activation to track upgrades.
  # nix-darwin only runs a fixed set of activation scripts; a custom key like
  # `linkEmacsApp` is never invoked. postActivation runs after the `homebrew`
  # step, so the formula is installed by the time we copy it.
  #
  # rm -rf the destination first: `cp -r src dest` nests src *inside* dest when
  # dest already exists, so without this the second activation would create
  # /Applications/Emacs.app/Emacs.app.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    if [ -e /opt/homebrew/opt/${emacsPlus.name}/Emacs.app ]; then
      rm -rf /Applications/Emacs.app /Applications/Emacs\ Client.app
      cp -r /opt/homebrew/opt/${emacsPlus.name}/Emacs.app /Applications/Emacs.app
      cp -r /opt/homebrew/opt/${emacsPlus.name}/Emacs\ Client.app /Applications/Emacs\ Client.app
    fi
  '';
}
