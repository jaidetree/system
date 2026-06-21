{ pkgs, lib, ... }:
let
  claudeStatusLine = pkgs.fetchFromGitHub {
    owner = "daniel3303";
    repo = "ClaudeCodeStatusLine";
    rev = "5da96959df726707fe8ff41c5645b4f7b8c7eac9";
    sha256 = "3ZJM7/xeY/i676DOmRh6157HUilzkVl+RTPFrErtVe0=";
  };
in
{
  home.file.".claude/statusline/statusline.sh" = {
    source = "${claudeStatusLine}/statusline.sh";
    executable = true;
  };

  home.activation.claudeStatusLine = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    if [ -f "$settings" ]; then
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline/statusline.sh"}}' "$settings" > "$tmp" && mv "$tmp" "$settings"
    else
      printf '%s\n' '{"statusLine": {"type": "command", "command": "~/.claude/statusline/statusline.sh"}}' > "$settings"
    fi
  '';
}
