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
    config.theme = "dracula";
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

  home.shellAliases = {
    cat = "bat";
    curl = "curlie";
  };
}
