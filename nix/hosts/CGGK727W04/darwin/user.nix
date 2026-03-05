{ pkgs, username, ... }: {
  system.primaryUser = username;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = "${pkgs.fish}/bin/fish";
    openssh.authorizedKeys.keys = [
    ];
  };
}
