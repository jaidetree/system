#!/usr/bin/env bash
# Regenerate the knowledge index from note frontmatter. Zero deps, no Obsidian.
# Usage: scan-knowledge.sh [vault/Knowledge]   (defaults to vault/Knowledge)
set -euo pipefail
dir="${1:-vault/Knowledge}"
[ -d "$dir" ] || { echo "no such dir: $dir" >&2; exit 1; }
shopt -s nullglob
for f in "$dir"/*.md; do
  base="$(basename "$f" .md)"
  [ "$base" = "INDEX" ] && continue
  desc="$(awk -F': ' '/^description:/{sub(/^description: */,"");print;exit}' "$f")"
  printf -- '- [[%s]] — %s\n' "$base" "$desc"
done
