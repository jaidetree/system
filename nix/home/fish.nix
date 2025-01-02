{ config, lib, pkgs, inputs, ... }:
let
  detectbg = inputs.detectbg.packages.${pkgs.system}.default;
in
{
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

    loginShellInit =
      let
        # We should probably use `config.environment.profiles`, as described in
        # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
        # but this takes into account the new XDG paths used when the nix
        # configuration has `use-xdg-base-directories` enabled. See:
        # https://github.com/LnL7/nix-darwin/issues/947 for more information.
        profiles = [
          "/etc/profiles/per-user/$USER/bin" # Home manager packages
          "$HOME/.nix-profile/bin"
          "(set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo $HOME/.local/state)/nix/profile/bin"
          "/run/current-system/sw/bin"
          "/nix/var/nix/profiles/default/bin"
        ];

        makeBinSearchPath =
          lib.concatMapStringsSep " " (path: "${path}");
      in
      ''
        # Fix path that was re-ordered by Apple's path_helper
        fish_add_path --move --prepend --path ${makeBinSearchPath profiles}
        set fish_user_paths $fish_user_paths
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
      multicd = "echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)";
      last_history_item = "echo $history[1]";
    };

    shellInitLast = ''
    '';
  };
}
