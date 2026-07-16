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
    onActivation.cleanup = "uninstall";
    onActivation.upgrade = true;

    taps = [
      {
        name = "d12frosted/emacs-plus";
        trusted = true;
      }
    ];
    brews = [
      "bchunk"
      "CrunchyData/brew/cb"
      emacsPlus
      "ffmpeg"
      "flyctl"
      "mosh"
      "paneru"
    ];
    casks = [
      "1password"
      "1password-cli"
      "affinity"
      "alfred"
      "anydesk"
      "arc"
      "balsamiq-wireframes"
      "blender"
      "claude-code"
      "cleanshot"
      "cursor"
      "daisydisk"
      "dropbox"
      "figma"
      "firefox@nightly"
      "floorp"
      "gather"
      "gifox"
      "gimp"
      "hammerspoon"
      "inkscape"
      "karabiner-elements"
      "linear"
      "livebook"
      "loopback"
      "mockoon"
      "monodraw"
      "notion"
      "obs"
      "obsidian"
      "openmtp"
      "parsec"
      "philips-hue-sync"
      "rocket"
      "rowmote-helper"
      "sketch"
      "soundsource"
      "spacedrive"
      "spotify"
      "uhk-agent"
      "utm"
      "wezterm"
      "zen"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Affinity Designer 2" = 1616831348;
      "ColorSlurp" = 1287239339;
      "Goodnotes 6" = 1444383602;
      "Kagi for Safari" = 1622835804;
      "MindNode Classic" = 1289197285;
      "MindNode" = 6446116532;
      "Slack for Desktop" = 803453959;
      # "Spectrum" = 518156125;
      "Tailscale" = 1475387142;
      "Unclutter" = 577085396;
      "Xcode" = 497799835;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
    };
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
