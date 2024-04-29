{ pkgs, ... }: {
  system.defaults.NSGlobalDomain = {
    AppleInterfaceStyle = "Dark";
    ApplePressAndHoldEnabled = false;
    AppleShowAllFiles = true;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    "com.apple.swipescrolldirection" = false;
  };

  system.defaults.dock = {
    autohide = true;
    magnification = true;
    largesize = 80;
    # persistent-apps = [ ];
  };

  system.defaults.finder = {
    FXDefaultSearchScope = "SCcf";
    FXEnableExtensionChangeWarning = false;
    QuitMenuItem = true;
    ShowPathbar = true;
  };

  system.defaults.screencapture = {
    disable-shadow = true;
  };

  system.defaults.screensaver.askForPassword = false;

  system.activationScripts.postUserActivation.text = ''
    # Following line should allow us to avoid a logout/login cycle
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
