{ pkgs, ... }:
let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
  secrets = import ../secrets;
in
{
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      containers = {
        personal = {
          id = 1;
          name = "Personal";
          icon = "fingerprint";
          color = "pink";
        };
        work = {
          id = 2;
          name = "Work";
          icon = "briefcase";
          color = "blue";
        };
      };
      extensions = with nur-no-pkgs.repos.rycee.firefox-addons; [
        adblocker-ultimate
        darkreader
        onepassword-password-manager
        sidebery
        tab-session-manager
        violentmonkey
      ];
      search = {
        force = true;
        engines = {
          "Kagi" = {
            urls = [{ template =
              "https://kagi.com/search?token=${secrets.kagiSessionToken}&q=${searchTerms}"; }];
            iconUpdateURL = "https://kagi.com/apple-touch-icon.png";
            definedAliases = ["kagi"];
          };
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];

            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };

          "NixOS Wiki" = {
            urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
        };
      };
      default = "Kagi";
      extraConfig = ''
      '';
      settings = {
          false;
        "browser.bookmarks.addedImportButton" = true;
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.section.highlights.includePocket" =
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.shell.didSkipDefaultBrowserCheckOnFirstRun" = true;
        "browser.startup.homepage" = "https://kagi.com/search";
        "browser.tabs.inTitleBar" = 0;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        # @TODO Get hostname?
        "identity.fxaccounts.account.device.name" = "";
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "trailhead.firstrun.didSeeAboutWelcome" = true;
      };
      userChrome = ''
        /* Hide tab bar in FF Quantum */
        @-moz-document url("chrome://browser/content/browser.xul") {
          #TabsToolbar {
            visibility: collapse !important;
            margin-bottom: 21px !important;
          }
        
          #sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
            visibility: collapse !important;
          }
        }
      '';
      userContent = ''
      '';
    };
  };
}
