# Plan: Dotfiles Reorganization

Status: **implemented 2026-07-05** (commits b69bf21, 4ba20b2, 61eb8fb, 9710ca0)
Owner: jaide
Created: 2026-07-05

## 1. Goal

Reorganize the repo so that (a) AI/agent config is a first-class top-level
concern, (b) the dotfiles source tree is a literal `$HOME` mirror, and (c)
`use.py` can link arbitrary sources to arbitrary destinations across multiple
hosts — including per-item linking into shared directories.

## 2. Context & current architecture

The repo is a two-stage symlink system:

1. **Source of truth** lives in `dotfiles/core/<tool>/` (→ `~/.config/<tool>`)
   and `dotfiles/core/homedir/*` (→ `$HOME`).
2. **`use.py`** spreads a core dir into per-host manifest dirs:
   `hosts/<host>/<tool> -> ../../core/<tool>` (relative symlinks).
   The per-host dir under `dotfiles/hosts/<host>/` *is* the manifest, expressed
   as a tree of symlinks and tracked in git.
3. **`link.py`** walks `dotfiles/hosts/$hostname/`, materializing symlinks into
   the live filesystem: top-level entries → `~/.config/<...>`, the special
   `homedir/` subtree → `$HOME/<...>`. It records everything in
   `~/.config/dotfiles.json` and removes stale links on re-run.

### Key constraint discovered during design

`~/.claude/skills/` is a **shared merge point**. It holds per-item symlinks from
two independent producers:

- The user's own skills → `/Users/j/system/skills/*`.
- nix-managed matt-pocock skills → `/nix/store/...`, dropped in by
  `nix/modules/home-manager/personal/claude-mattpocock-skills.nix` during
  home-manager activation (`link-skills.sh`).

Therefore `~/.claude/skills/` must **always remain a real directory populated by
per-item symlinks**. It can never become a single directory-symlink, or nix's
matt-pocock skills would be clobbered. This is why skill linking must be
per-item (glob), not whole-directory.

## 3. Design decisions (locked)

1. **Keep the two-stage model.** Host dir stays the git-tracked manifest;
   `link.py` still materializes. `use.py` writes into it.
2. **Host manifest = `$HOME` mirror.** Each entry's path under `hosts/<host>/`
   equals its destination path relative to `$HOME`. `~/.config/x` is just
   `.config/x`. No home/config split, no filename prefixes. `link.py` collapses
   to a single identity rule: `~/<relpath> -> target`.
3. **Source tree is a literal `$HOME` mirror too.** `dotfiles/` mirrors `$HOME`:
   - `dotfiles/core/<tool>` → **`dotfiles/.config/<tool>`** (note the dot).
   - `dotfiles/core/homedir/*` → **`dotfiles/*`** (repo-root of the mirror),
     e.g. `dotfiles/.npmrc`, `dotfiles/prettier.config.ts`.
   Identity mapping means `link.py`/`use.py` need **no** mapping table for
   `dotfiles/` sources.
4. **`ai/` is the one source area outside the mirror.** It is grouped by concern
   and lands in `~/.claude`. It carries its own **`ai/links.json`** manifest
   (JSON, stdlib only) declaring `src`→`dest`:
   ```json
   {
     "links": [
       { "src": "CLAUDE.md", "dest": ".claude/CLAUDE.md" },
       { "src": "skills/*",  "dest": ".claude/skills/" }
     ]
   }
   ```
   - `src` is relative to the manifest dir (`ai/`); may be a glob.
   - `dest` is relative to `$HOME`. A trailing `/` (or a glob `src`) ⇒ dest is a
     directory and the source basename is appended per item (→ per-item links
     that keep `~/.claude/skills/` a real dir).
5. **`use.py` new signature: `dot use <src> <host>...`** (no dest arg).
   - If `<src>` is a directory containing `links.json` → read it, apply every
     rule to each named host.
   - Else (`<src>` under `dotfiles/`) → identity mirror: dest = src path minus
     the `dotfiles/` prefix.
   - Globs must be quoted so `use.py` receives one arg and expands internally.
   - Hosts are trailing CLI args (per-host selection stays on the CLI; the
     manifest only says *what maps where*, never *which machines*).
6. **`hosts/` moves to repo root** (from `dotfiles/hosts/`).
7. **Symlink targets in the host manifest are relative** (matches current
   `use.py`), e.g. `hosts/<host>/.config/nvim -> ../../../dotfiles/.config/nvim`,
   `hosts/<host>/.claude/skills/commit -> ../../../../ai/skills/commit`.

## 4. Target layout

```
system/
  ai/
    CLAUDE.md                 # was dotfiles/core/homedir/.claude/CLAUDE.md
    links.json                # new manifest, read by use.py
    skills/                   # was top-level skills/
      commit/ feature/ iterate/ precommit-review/ project/ update-learnings/
  dotfiles/
    .config/                  # was dotfiles/core/ (tool dirs)
      clojure-lsp/ doom/ emacs-plus/ karabiner/ nvim/ ripgrep/
      spacehammer/ tmux/ wezterm/ zellij/
    .npmrc                    # was dotfiles/core/homedir/.npmrc
    prettier.config.ts        # was dotfiles/core/homedir/prettier.config.ts
  hosts/                      # was dotfiles/hosts/
    <host>/
      .config/<tool> -> ../../../dotfiles/.config/<tool>
      .npmrc         -> ../../../dotfiles/.npmrc
      prettier.config.ts -> ../../../dotfiles/prettier.config.ts
      .claude/CLAUDE.md -> ../../../../ai/CLAUDE.md
      .claude/skills/<name> -> ../../../../ai/skills/<name>
  scripts/ bin/ nix/ ...
```

## 5. Per-host regeneration matrix

Derived from current `dotfiles/hosts/*`:

| host           | tools (all under `.config/`)                                              | homedir today | gets `ai/` |
|----------------|--------------------------------------------------------------------------|---------------|------------|
| j-bakotsu-mbp  | clojure-lsp doom emacs-plus karabiner nvim ripgrep spacehammer tmux wezterm zellij | yes | yes |
| j-oni-mbp      | clojure-lsp doom emacs-plus karabiner nvim ripgrep spacehammer tmux wezterm zellij | yes | yes |
| CGGK727W04     | clojure-lsp doom emacs-plus karabiner nvim ripgrep spacehammer tmux wezterm zellij | **no**  | **no** (preserve current) |
| sf-cloud-ws    | emacs-plus nvim ripgrep tmux zellij                                        | bare entry — inspect | yes if it currently resolves |

Notes / landmines:
- **CGGK727W04** has no `homedir` entry today → currently gets no CLAUDE.md,
  skills, or `.npmrc`. Preserve that: do **not** run `dot use ai` for it unless
  the user asks. Its `tmux` is an absolute symlink under a different username
  (`/Users/jzawrotny/system/...`); regenerating with relative links fixes this
  incidentally.
- **sf-cloud-ws** shows a bare `homedir` entry (no arrow). Inspect whether it is
  a real dir, a symlink, or dangling before deciding whether it gets `ai/` and
  the home dotfiles.

## 6. Work breakdown (proposed commits)

1. **Move files (`git mv`)**
   - `dotfiles/core/homedir/.claude/CLAUDE.md` → `ai/CLAUDE.md`
   - top-level `skills/` → `ai/skills/`
   - `dotfiles/core/homedir/{.npmrc,prettier.config.ts}` → `dotfiles/{.npmrc,prettier.config.ts}`
   - `dotfiles/core/*` (remaining tool dirs) → `dotfiles/.config/*`
   - `dotfiles/hosts/` → `hosts/`
   - remove now-empty `dotfiles/core/homedir` and `dotfiles/core`
   - add `ai/links.json`
2. **Rewrite `link.py`** — single `$HOME`-mirror walk over `hosts/$hostname/`;
   drop the `~/.config` vs `homedir/` special-casing and the `homedir`
   IGNORE_DIRS entry; update `host_dir` to `system_root/'hosts'/hostname`;
   update docstrings. Manifest path (`~/.config/dotfiles.json`) unchanged.
3. **Rewrite `use.py`** — new `dot use <src> <host>...` signature; manifest mode
   (`links.json` present) vs identity-mirror mode; quoted-glob expansion;
   per-item link creation; `hosts_root = system_root/'hosts'`.
4. **Regenerate host manifests + docs/scripts**
   - Delete old `hosts/<host>/` trees; regenerate via new `use.py` per §5.
   - Run `dot link` **live on j-bakotsu-mbp only**; verify (see §7).
   - Update `README.md` fully.
   - Minimally repath `lift.py`, `explode.py`, `implode.py`
     (`dotfiles/core`→`dotfiles`, `dotfiles/hosts`→`hosts`) so they don't break.
   - Update comments in `nix/rebuild.sh`, `nix/hosts/*/home-manager/dotfiles.nix`.

## 7. Acceptance criteria

- [ ] `ai/CLAUDE.md`, `ai/skills/*`, `ai/links.json` exist; top-level `skills/`
      and `dotfiles/core/` are gone.
- [ ] `dotfiles/.config/<tool>` and `dotfiles/{.npmrc,prettier.config.ts}` exist
      with full git history (moved via `git mv`).
- [ ] `hosts/` is at repo root; each host manifest is a `$HOME`-shaped tree of
      **relative** symlinks matching §4/§5.
- [ ] `dot use dotfiles/.config/emacs j-oni-mbp` → creates
      `hosts/j-oni-mbp/.config/emacs -> ../../../dotfiles/.config/emacs`.
- [ ] `dot use ai j-oni-mbp` → creates `hosts/j-oni-mbp/.claude/CLAUDE.md`
      and per-skill `hosts/j-oni-mbp/.claude/skills/<name>` entries from
      `ai/links.json`.
- [ ] `dot link` on j-bakotsu-mbp exits cleanly and:
  - `~/.config/<tool>` resolves into `dotfiles/.config/<tool>` for every tool.
  - `~/.npmrc`, `~/prettier.config.ts` resolve into `dotfiles/`.
  - `~/.claude/CLAUDE.md` resolves into `ai/CLAUDE.md`.
  - `~/.claude/skills/{commit,feature,iterate,precommit-review,project,update-learnings}`
    resolve into `ai/skills/*`.
  - `~/.claude/skills/` **still contains** the nix/matt-pocock links
    (`ask-matt`, `code-review`, …) — none removed.
- [ ] No dangling symlinks under `~/.claude/` or `~/.config/` after `dot link`.
- [ ] `dot link --dry-run` on the other hosts' manifests shows the expected
      links (spot check; not applied live).
- [ ] `README.md` describes the new layout and `dot use`/`dot link` behavior.

## 8. Out of scope

- Running `dot link` live on any host other than **j-bakotsu-mbp**. Other hosts
  apply the new manifests themselves on next sync.
- Adding `ai/` to **CGGK727W04** (preserve its current no-AI state).
- Deep rework of `lift.py` (its "share to core" semantics), `explode.py`,
  `implode.py` beyond minimal repathing. Follow-up if desired.
- Supporting multiple *agents* beyond the single `ai/` group (e.g. `~/.codex`,
  `~/.cursor`). The `links.json` mechanism is designed to allow it, but no
  second group is created now.
- Per-host *subsetting* of skills (all skills in `ai/links.json` apply wholesale
  to each named host).
- Migrating the nix/matt-pocock skill mechanism — it stays as is; the plan only
  guarantees coexistence.
- Changing the manifest file location/format (`~/.config/dotfiles.json` stays).

## 9. Open items to resolve during execution

- Inspect `sf-cloud-ws`'s bare `homedir` entry before regenerating it.
- Confirm relative-link depth is correct for nested `.claude/skills/<name>`
  entries (`../../../../ai/skills/<name>`).
- Decide commit granularity at execution time (default: the 4 commits in §6).
