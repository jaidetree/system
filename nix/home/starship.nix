{ pkgs, ... }:
let
  flavor = "mocha";
in
{
  programs.starship = {
    enable = true;
    enableTransience = true;
    settings = {
      format = ''
        $directory$line_break$all$line_break$character
      '';
      cmd_duration = {
        disabled = true;
      };
      directory = {
        truncate_to_repo = false;
        fish_style_pwd_dir_length = 1;
      };
      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style) ";
      };
      nix_shell = {
        format = "[$symbol]($style)";
        symbol = "❄️ ";
      };
      nodejs = {
        disabled = true;
      };
      ocaml = {
        disabled = true;
      };
      shell = {
        disabled = false;
        fish_indicator = "";
        zsh_indicator = "󰬡";
      };

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
