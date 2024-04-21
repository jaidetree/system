{ pkgs, ... }: {
  users.users.j = {
    name = "j";
    home = "/Users/j";
    shell = "${pkgs.fish}/bin/fish";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKp8h8EqgE4zweHbotyCOvjvBzgxn40trCCYULLBIV/6"
    ];
  };
}
