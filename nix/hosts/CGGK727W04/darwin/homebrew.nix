{ pkgs, ... }:
{
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    onActivation.upgrade = true;

    # Required for sf CLI
    taps = [
      "snowflakedb/cloudeng"
      {
        name = "snowflakedb/snowflake-cli";
        trusted = true;
      }
    ];
    brews = [
      "ffmpeg"
      "snowflakedb/cloudeng/yetis"
      "snowflake-cli"
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
