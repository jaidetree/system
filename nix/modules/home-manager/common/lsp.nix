{ pkgs, ... }: {
  home.packages = [
    pkgs.nil
    pkgs.prettier
    # pkgs.nodePackages_latest.typescript-language-server
    pkgs.tailwindcss-language-server
    pkgs.typos-lsp
  ];
}
