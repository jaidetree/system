# System Configuration

Provides system configuration between a few computers and a cloud workspace.

## Concept

I like nix but I don't like having all of my dotfiles in nix as it makes it harder to write custom configs for nvim and zellij quickly. This setup supports static config files while using nix for the bones and general package management.

## How it Works

Dotfiles live in `dotfiles/core/` organized by app (nvim, zellij, tmux, etc.). Each host gets a directory under `dotfiles/hosts/<hostname>/` that symlinks back to the core configs it needs. A host directory might also contain real files for machine-specific overrides.

Running `dot link` walks the current host's directory and creates symlinks from `~/.config/` into the repo. It tracks everything in a manifest (`~/.config/dotfiles.json`) so it can clean up stale links on subsequent runs.

The `nix/` directory handles system-level configuration with nix-darwin and home-manager. The `nix/rebuild.sh` script runs `dot link` first, then kicks off the nix-darwin rebuild.

To add a new config, either drop files into `dotfiles/core/` and symlink them from your host directory, or use `dot lift` to migrate an existing `~/.config/` entry into the repo interactively.

## Utils

All utilities are accessed through the `dot` command, which dispatches to scripts in `scripts/`.

- `dot link [--dry-run] [--hostname NAME]` — Sync symlinks from the host's dotfiles directory into `~/.config/`. Removes stale links, creates new ones, and updates the manifest.
- `dot lift <path>` — Move a config out of `~/.config/` and into the dotfiles structure. Prompts whether to put it in core (shared) or keep it host-specific, then replaces the original with a symlink.
- `dot explode <path> [--deep]` — Break a directory symlink into individual file symlinks. Useful when you need to override a single file within a config that was previously linked as a whole directory.
- `dot implode <path>` — Reverse of explode. Collapses a directory of individual symlinks back into a single directory symlink, provided they all point to the same parent.
