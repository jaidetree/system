{ pkgs, config, ... }:
let
  vimEmacsPane = pkgs.fetchFromGitHub {
    owner = "laishulu";
    repo = "emacs-tmux-pane";
    rev = "0ab0d40b497e984a589189358e04e322b8165985";
    sha256 = "DPMvRFUM3+Qr0PSqU30zwSEHxSl5NxOVH9PieLQwtlI=";
  };
  catppuccin = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    rev = "5ed4e8a6a20c928688da268dfcdf460ac9c3cb49";
    sha256 = "k9Ihfk8C1jYkGUvOcgLwS4UdXR8d/4Nu/Dyh03FpDZc=";
  };
in
{
  home.packages = [
    pkgs.fzf
  ];

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    customPaneNavigationAndResize = true;
    keyMode = "vi";
    mouse = true;
    shell = "${pkgs.fish}/bin/fish";
    historyLimit = 5000;
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      # catppuccin - Last version was 2021
      open
      prefix-highlight
      tmux-fzf
      vim-tmux-navigator
      yank
    ];

    extraConfig = ''
      run-shell ${vimEmacsPane}/tmux-pane.tmux

      source ${config.xdg.configHome}/tmux/theme.tmux
      run-shell ${catppuccin}/catppuccin.tmux

      set -g -u default-command "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${pkgs.fish}/bin/fish"
      set -g allow-rename off
      set -g xterm-keys on
      set -ga terminal-overrides ",xterm-256color*:Tc"
      set -as terminal-features ",xterm-256color:RGB"

      # Move between panes without the prefix
      bind-key -r C-h select-window -t :-
      bind-key -r c-l select-window -t :+

      # Make copy-mode a bit more vim like
      bind-key -T copy-mode-vi v   send-keys -X begin-selection
      bind-key -T copy-mode-vi V   send-keys -X select-line
      bind-key -T copy-move-vi C-V send-keys -X begin-selection \; send -X rectangle-toggle

      # Resize with arrow keys
      bind-key -r M-Down  resize-pane -D 5
      bind-key -r M-Up    resize-pane -U 5
      bind-key -r M-Left  resize-pane -L 20
      bind-key -r M-Right resize-pane -R 20

      # Vim inspired splitting shortcuts
      bind-key K split-window
      bind-key J split-window
      bind-key H split-window -h
      bind-key L split-window -h
      bind-key / split-window -h
      bind-key - split-window -v
      
      # Every once in a while I convince myself nested tmux-sessions will be fun
      bind-key b send-prefix
    '';

  };
}
