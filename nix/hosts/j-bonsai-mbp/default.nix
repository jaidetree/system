{config, pkgs, ... }: {
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixUnstable;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "root" "j" ];
    };
    extraOptions = ''
    warn-dirty = false
    log-lines = 40
    connect-timeout = 5
    min-free = 128000000 # 128mb
    max-free = 1000000000 # 1gb
    builders-use-substitutes = true
    '';
  };
  system.configurationRevision = config.rev or config.dirtyRev or null;
  system.stateVersion = 4;
  
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowUnfree = true;
  };

  users.users.j = {
    name = "j";
    home = "/Users/j";
    shell = "${pkgs.fish}/bin/fish";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp8h8EqgE4zweHbotyCOvjvBzgxn40trCCYULLBIV/6"
    ];
  };

  programs.zsh.enable = true;
  programs.fish.enable = true;
  programs.direnv.enable = true;

  environment = {
    systemPackages = [ 
    ];
    systemPath = [
      "/opt/homebrew/bin"
    ];
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    shells = [ pkgs.fish ];
  };
 
  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";

    taps = [];
    brews = [
    ];
    casks = [
      "1password"
      "1password-cli"
      "alfred"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
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
