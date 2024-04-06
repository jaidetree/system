{ pkgs, ... }:
{
  home.packages = [
    pkgs.curlie
    pkgs.fd
    pkgs.fx
    pkgs.fzf
    pkgs.jq
    pkgs.neofetch
    pkgs.ripgrep
  ];

  programs.bat = {
    enable = true;
    config.theme = "catppuccin";
    themes = {
      dracula = {
	src = pkgs.fetchFromGitHub {
	  owner = "dracula";
	  repo = "sublime"; # Bat uses sublime syntax for its themes
	    rev = "26c57ec282abcaa76e57e055f38432bd827ac34e";
	  sha256 = "019hfl4zbn4vm4154hh3bwk6hm7bdxbr1hdww83nabxwjn99ndhv";
	};
	file = "Dracula.tmTheme";
      };
      catppuccin = {
	src = pkgs.fetchFromGitHub {
	  owner = "catppuccin";
	  repo = "bat"; # Bat uses sublime syntax for its themes
	    rev = "b19bea35a85a32294ac4732cad5b0dc6495bed32";
	  sha256 = "POoW2sEM6jiymbb+W/9DKIjDM1Buu1HAmrNP0yC2JPg=";
	};
	file = "themes/Catppuccin Mocha.tmTheme";
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      vim_keys = true;
    };
  };

  programs.zsh.enable = true;

  programs.zoxide.enable = true;

  home.shellAliases = {
    cat = "bat";
    curl = "curlie";
  };
}
