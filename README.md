# System Configuration

Provides system configuration between a few computers and a cloud workspace.

## Concept

I like nix but I don't like having all of my dotfiles in nix as it makes it harder to write custom configs for nvim and zellij quickly. This setup supports static config files while using nix for the bones and general package management.

## Layout

```
system/
  ai/                     # AI/agent config, grouped by concern
    CLAUDE.md             # -> ~/.claude/CLAUDE.md
    links.json            # manifest read by `dot use`
    skills/               # -> ~/.claude/skills/<name> (per-item links)
  dotfiles/               # literal $HOME mirror (source of truth)
    .config/<tool>/       # -> ~/.config/<tool>
    .npmrc                # -> ~/.npmrc
    prettier.config.ts    # -> ~/prettier.config.ts
  hosts/<hostname>/       # per-host manifests: $HOME-shaped symlink trees
  scripts/ bin/ nix/ ...
```

## How it Works

It is a two-stage symlink system:

1. **`dot use <src> <host>...`** spreads a source into one or more host manifest directories under `hosts/<hostname>/`. The host directory *is* the manifest: a `$HOME`-shaped tree of relative symlinks (plus the occasional real file for machine-specific overrides, e.g. `hosts/sf-cloud-ws/.npmrc`), tracked in git.
2. **`dot link`** walks `hosts/$hostname/` and materializes it into the live filesystem with one identity rule: an entry at `hosts/<host>/<relpath>` becomes the symlink `~/<relpath>`. Everything it creates is tracked in `~/.config/dotfiles.json` so stale links are cleaned up on subsequent runs.

`dot use` has two modes:

- **Identity mode** — `<src>` is under `dotfiles/`, which mirrors `$HOME`, so the destination is just the source path minus the `dotfiles/` prefix: `dot use dotfiles/.config/nvim j-oni-mbp` creates `hosts/j-oni-mbp/.config/nvim -> ../../../dotfiles/.config/nvim`. `<src>` may be a glob, quoted so the shell passes it through: `dot use 'dotfiles/.config/*' j-oni-mbp`.
- **Manifest mode** — `<src>` is a directory containing a `links.json` declaring `src`→`dest` rules (`src` relative to the manifest dir, `dest` relative to `$HOME`). A glob `src` or trailing `/` on `dest` links each matched item individually into the dest directory. `dot use ai j-oni-mbp` links `ai/CLAUDE.md` to `.claude/CLAUDE.md` and each skill to `.claude/skills/<name>`.

Per-item skill links matter: `~/.claude/skills/` is a shared merge point between these skills and nix-managed ones (see `nix/modules/home-manager/personal/claude-mattpocock-skills.nix`), so it must stay a real directory of per-item symlinks — never a single directory symlink.

The `nix/` directory handles system-level configuration with nix-darwin and home-manager. The `nix/rebuild.sh` script runs `dot link` first, then kicks off the nix-darwin rebuild.

To add a new config, drop files into `dotfiles/` at their `$HOME`-mirrored path and run `dot use` for each host that needs them, or use `dot lift` to migrate an existing `~/.config/` entry into the repo interactively.

## Per-host Matrix

| host          | `.config/` tools                                                                    | home dotfiles              | `ai/` |
|---------------|-------------------------------------------------------------------------------------|----------------------------|-------|
| j-bakotsu-mbp | clojure-lsp doom emacs-plus karabiner nvim ripgrep spacehammer tmux wezterm zellij  | .npmrc, prettier.config.ts | yes   |
| j-oni-mbp     | clojure-lsp doom emacs-plus karabiner nvim ripgrep spacehammer tmux wezterm zellij  | .npmrc, prettier.config.ts | yes   |
| CGGK727W04    | clojure-lsp doom emacs-plus karabiner nvim ripgrep spacehammer tmux wezterm zellij  | —                          | no    |
| sf-cloud-ws   | emacs-plus nvim ripgrep tmux zellij                                                 | own real `.npmrc`          | no    |

## Claude Skills

Skills extend Claude Code with slash commands. Shared skills live in `ai/skills/` and are linked into `~/.claude/skills/` via `dot use ai <host>`. Project-level skills live in `.claude/skills/` and are available in any Claude Code session within this repo.

- `/add-nix-github-module` — Pin a GitHub repo into home-manager: fetch it, link files or run scripts from it. Handles `fetchFromGitHub` (self-contained, no flake changes) and flake input (tracked in `flake.lock`) patterns. Places modules in `nix/modules/home-manager/personal/` which is auto-imported on personal machines.

## Utils

All utilities are accessed through the `dot` command, which dispatches to scripts in `scripts/`.

- `dot use <src> <host>... [--dry-run] [--force]` — Link a repo source (a `dotfiles/` entry, a quoted glob, or a dir with `links.json`) into one or more host manifest directories as relative symlinks.
- `dot link [--dry-run] [--hostname NAME]` — Materialize the host manifest `hosts/$hostname/` into `$HOME`. Removes stale links, creates new ones, and updates `~/.config/dotfiles.json`.
- `dot lift <path>` — Move a config out of `~/.config/` and into the repo. Prompts whether to put it in `dotfiles/` (shared) or keep it host-specific, then replaces the original with a symlink.
- `dot explode <path> [--deep]` — Break a directory symlink into individual file symlinks. Useful when you need to override a single file within a config that was previously linked as a whole directory.
- `dot implode <path>` — Reverse of explode. Collapses a directory of individual symlinks back into a single directory symlink, provided they all point to the same parent.
