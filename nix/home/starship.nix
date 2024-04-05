{ pkgs, ... }:
let 
  flavor = "mocha";
in
{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      format = "$all";
      palette = "catppuccin_${flavor}";
    } // builtins.fromTOML (builtins.readFile
    (pkgs.fetchFromGitHub
      {
	owner = "catppuccin";
	repo = "starship";
	rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f";
	sha256 = "nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
      } + /palettes/${flavor}.toml));
  };
}
