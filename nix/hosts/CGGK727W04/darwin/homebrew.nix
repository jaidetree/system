{ pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    onActivation.upgrade = true;

    # Required for sf CLI
    taps = [
      "snowflakedb/cloudeng"
    ];
    brews = [
      "ffmpeg"
      "snowflakedb/cloudeng/yetis"
    ];

    # GUI Applications
    casks = [
      "1password"
      "1password-cli"
      "colemak-dh"
      "cursor"
      "firefox"
      "gimp"
      "hammerspoon"
      "inkscape"
      "obsidian"
      "wezterm"
    ];

    # masApps = { };
  };
}
