#!/usr/bin/env bash
# Bootstrap script for cloud workspaces
#
# NOTE: The canonical version of this script lives in dev-config:
# ~/projects/dev-config/configs/jzawrotny/cloud-workspaces/default/init-cloud-ws.sh
#
# This copy is kept for reference/documentation purposes.
# Changes should be made in dev-config, not here.

set -e

echo "=== Cloud Workspace Setup ==="
echo

# 1. Prompt for SSH private key (from 1Password)
echo "Paste your personal SSH private key (from 1Password):"
read -s -r ssh_private_key

if [ -z "$ssh_private_key" ]; then
    echo "Error: No key provided" >&2
    exit 1
fi

# 2. Setup SSH key
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$ssh_private_key" > ~/.ssh/id_ed_personal
chmod 600 ~/.ssh/id_ed_personal

# 3. Clone system repo (use GIT_SSH_COMMAND to specify key)
echo "Cloning system repo..."
if [ ! -d ~/system ]; then
    GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed_personal" \
      git clone git@github.com:jaidetree/system.git ~/system
else
    echo "~/system already exists, pulling latest..."
    cd ~/system && GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed_personal" git pull
fi

# 4. Configure system repo to use regular SSH (not sf __ssh)
# This will be handled by .envrc (see below)
cd ~/system

# 5. Run dotlink to create symlinks
echo "Creating dotfile symlinks..."
~/system/scripts/link.py

# 6. Install direnv if not already installed
if ! command -v direnv &> /dev/null; then
    echo "Installing direnv..."
    nix-env -iA nixpkgs.direnv
fi

# 7. Install and switch to home-manager config
echo "Installing home-manager configuration..."
if ! command -v home-manager &> /dev/null; then
    nix-shell -p home-manager --run \
      "home-manager switch --flake ~/system/nix#jzawrotny-sf-cloud-ws"
else
    home-manager switch --flake ~/system/nix#jzawrotny-sf-cloud-ws
fi

# 8. Enable direnv for system repo
cd ~/system
direnv allow

echo
echo "=== Setup complete! ==="
echo "Config: ~/system"
echo "Dotfiles: ~/.config (symlinked via link.py)"
echo "Git SSH: Configured via .envrc (direnv)"
