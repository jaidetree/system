{ pkgs, ... }: {
  home.packages = [
    pkgs.nil
    # pkgs.nodePackages_latest.prettier
    # pkgs.nodePackages_latest.typescript-language-server
    # pkgs.tailwindcss-language-server
  ];
}
