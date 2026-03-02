#!/usr/bin/env bash

# Darwin rebuild script with logging
# Shows colors in terminal, strips them from log file

# Determine script directory and system root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_ROOT="$HOME/system"
LOGFILE="$HOME/system/nix/rebuild.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Helper function to strip ANSI color codes
strip_colors() {
  sed $'s/\x1b\\[[0-9;]*[mGKHF]//g'
}

# Run link.py to update dotfile symlinks
echo "=== Updating dotfile symlinks ==="
"$SYSTEM_ROOT/bin/link.py"
if [ $? -ne 0 ]; then
  echo "Error: Failed to update dotfile symlinks" >&2
  exit 1
fi
echo ""

echo "=== Darwin Rebuild Started at $TIMESTAMP ==="
echo "Running: sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake $SCRIPT_DIR"
echo ""

# Write header to log file (without colors)
{
  echo "=== Darwin Rebuild Started at $TIMESTAMP ==="
  echo "Running: sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake $SCRIPT_DIR"
  echo ""
} > "$LOGFILE"

# Run the command: show colors in terminal, strip them for log file
sudo nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake "$SCRIPT_DIR" 2>&1 | \
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
