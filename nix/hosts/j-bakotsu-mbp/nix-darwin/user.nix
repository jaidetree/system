{ pkgs, ... }: {
  users.users.j = {
    name = "j";
    home = "/Users/j";
    shell = "${pkgs.fish}/bin/fish";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp8h8EqgE4zweHbotyCOvjvBzgxn40trCCYULLBIV/6"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTloAneEDSjfNCTDN15nAFesCFq6n+1rxpWt2rSIPrT"
      "sk-ecdsa-sha2-nistp256@openssh.com AAAAInNrLWVjZHNhLXNoYTItbmlzdHAyNTZAb3BlbnNzaC5jb20AAAAIbmlzdHAyNTYAAABBBDj8OnzUQSpfsg5rg18h47gJwChmx2cnH1WlOBtMwRt6sYcvowLX8PrBerZOu+AJ48urJ0wLHfMj6dQwaTbtSe8AAAAUaWRfZWNkc2Ffc2tAYmxpbmsuc2g= j@office-ipad"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+qcuBLOeAcAayG3R3T10Y0Nv6RSjpjBIbxDrY2ayiw jayzawrotny@gmail.com"
    ];
  };
}
