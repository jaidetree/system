{ pkgs, config, ... }:
let
  brewPrefix = config.homebrew.brewPrefix;
in
{
  environment.systemPackages = [
    pkgs.mosh
  ];

  launchd.agents."org.mosh.moshfw" = {
    script = ''
      #!/usr/bin/env bash
      FW=/usr/libexec/ApplicationFirewall/socketfilterfw
      MOSH=$(sudo -iu '#501' ${brewPrefix}/brew info mosh|grep Cellar|awk '{print $1}')/bin/mosh-server
      echo $MOSH 
      sudo $FW --add $MOSH
      sudo $FW --unblockapp $MOSH
    '';
    serviceConfig = {
      Label = "org.mosh.moshfw";
      Disabled = false;
      RunAtLoad = true;
      KeepAlive = false;
      LaunchOnlyOnce = true;
    };
  };
}
