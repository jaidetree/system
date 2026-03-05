#!/usr/bin/env bash

# Darwin rebuild script with logging
# Shows colors in terminal, strips them from log file

# Determine script directory and system root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SYSTEM_ROOT="$HOME/system"
LOGFILE="$HOME/system/logs/rebuild.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Helper function to strip ANSI color codes
strip_colors() {
  sed $'s/\x1b\\[[0-9;]*[mGKHF]//g'
}

mkdir -p $HOME/system/logs

# Run link.py to update dotfile symlinks
echo "=== Updating dotfile symlinks ==="
"$SYSTEM_ROOT/bin/dot" link
if [ $? -ne 0 ]; then
  echo "Error: Failed to update dotfile symlinks" >&2
  exit 1
fi
echo ""

# Check for unstaged .nix files
cd "$SYSTEM_ROOT"
UNSTAGED_NIX=$(git ls-files --modified --others --exclude-standard nix/ | grep '\.nix$')
if [ -n "$UNSTAGED_NIX" ]; then
  echo "=== Unstaged .nix files detected ==="
  echo "$UNSTAGED_NIX"
  echo ""
  read -p "Stage these files before rebuild? [Y/n]: " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "$UNSTAGED_NIX" | xargs git add
    echo "Files staged."
  else
    echo "Skipping staging. Note: Nix flakes only include tracked files."
  fi
  echo ""
fi

echo "=== Darwin Rebuild Started at $TIMESTAMP ==="
echo "Running: sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake $NIX_DIR"
echo ""

# Write header to log file (without colors)
{
  echo "=== Darwin Rebuild Started at $TIMESTAMP ==="
  echo "Running: sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake $NIX_DIR"
  echo ""
} > "$LOGFILE"

# Run the command: show colors in terminal, strip them for log file
sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake "$NIX_DIR" 2>&1 | \
  tee >(strip_colors >> "$LOGFILE")

# Capture the exit code
EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "=== Darwin Rebuild Finished at $(date '+%Y-%m-%d %H:%M:%S') ==="
echo "Exit code: $EXIT_CODE"
echo ""
echo "Log file saved to: $LOGFILE"

# Write footer to log file (without colors)
{
  echo ""
  echo "=== Darwin Rebuild Finished at $(date '+%Y-%m-%d %H:%M:%S') ==="
  echo "Exit code: $EXIT_CODE"
} >> "$LOGFILE"

exit $EXIT_CODE
