{ pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    onActivation.upgrade = true;

    taps = [
      "anchordotdev/tap"
    ];
    brews = [
      "anchordotdev/tap/anchor"
      "CrunchyData/brew/cb"
      "ffmpeg"
      "flyctl"
      "mosh"
    ];
    casks = [
      "1password"
      "1password-cli"
      "alfred"
      "arc"
      "balsamiq-wireframes"
      "blender"
      "cleanshot"
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
      "linear-linear"
      "loopback"
      "monodraw"
      "neovide"
      "notion"
      "rocket"
      "soundsource"
      "spacedrive"
      "spotify"
      "teamviewer"
      "uhk-agent"
      "zen-browser"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Affinity Designer 2" = 1616831348;
      "ColorSlurp" = 1287239339;
      "Goodnotes 6" = 1444383602;
      "Kagi for Safari" = 1622835804;
      "MindNode" = 1289197285;
      "Slack for Desktop" = 803453959;
      "Spectrum" = 518156125;
      "Tailscale" = 1475387142;
      "Unclutter" = 577085396;
      "Xcode" = 497799835;
      "Microsoft Excel" = 462058435;
      "Microsoft PowerPoint" = 462062816;
    };
  };
}
