{ pkgs, hostname, ... }: {
  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
  };
}

