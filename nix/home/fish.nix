{ pkgs, inputs, mylib, ... }:
  let
    detectbg = inputs.detectbg.packages.${pkgs.system}.default;
in
{
  home.packages = [
    inputs.oblique.packages.${pkgs.system}.default
  ];

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd j"
    ];
  };

  programs.direnv = {
    enable = true;
    # Not needed with fish
    # enableFishIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;

    shellInit = ''
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end
    '';

    interactiveShellInit = ''
      set -gx DIRENV_LOG_FORMAT ""

      abbr --add dotdot --regex '^\.\.+$' --function multicd
      abbr -a !! --position anywhere --function last_history_item

      function set_colorfgbg --on-signal WINCH # --on-event fish_prompt
        if test $SHLVL -eq 1
          set -gx COLORFGBG (${detectbg}/bin/detectbg "0;15" "15;0")
        end
      end
    '';

    functions = {
      fish_greeting = "oblique";
      multicd = "echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)";
      last_history_item = "echo $history[1]";
    };
  };
}
