{ pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    taps = [
      "anchordotdev/tap"
    ];
    brews = [
      "anchordotdev/tap/anchor"
    ];
    casks = [
      "1password"
      "1password-cli"
      "alfred"
      "arc"
      "blender"
      "dropbox"
      "figma"
      "gimp"
      "hammerspoon"
      "inkscape"
      "karabiner-elements"
      "linear-linear"
      "neovide"
      "notion"
      "rewind"
      "rocket"
      "spacedrive"
      "spotify"
      "teamviewer"
      "uhk-agent"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Affinity Designer 2" = 1616831348;
      "ColorSlurp" = 1287239339;
      "Gifox 2: GIF Recorder & Editor" = 1461845568;
      "Goodnotes 6" = 1444383602;
      "Kagi for Safari" = 1622835804;
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
