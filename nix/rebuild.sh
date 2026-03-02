#!/usr/bin/env bash

# Darwin rebuild script with logging
# Shows colors in terminal, strips them from log file

LOGFILE="$HOME/.config/nix/rebuild.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Helper function to strip ANSI color codes
strip_colors() {
  sed $'s/\x1b\\[[0-9;]*[mGKHF]//g'
}

echo "=== Darwin Rebuild Started at $TIMESTAMP ==="
echo "Running: sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ~/.config/nix"
echo ""

# Write header to log file (without colors)
{
  echo "=== Darwin Rebuild Started at $TIMESTAMP ==="
  echo "Running: sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ~/.config/nix"
  echo ""
} > "$LOGFILE"

# Run the command: show colors in terminal, strip them for log file
sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ~/.config/nix 2>&1 | \
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
