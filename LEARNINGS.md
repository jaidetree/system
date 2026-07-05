# Project Learnings

## Patterns That Work

- [2026-07-05] Making script walk functions take explicit `(host_dir, home,
  system_root)` params instead of hardcoding `Path.home()` made link.py
  testable with tmp-dir fixtures and stdlib unittest — no live-home risk.
- [2026-07-05] For repo-wide `git mv` reorgs with unrelated staged files
  (`nix/flake.nix`), unstage → commit explicit paths → re-stage keeps the
  commit clean without losing the user's staged state.

## Mistakes to Avoid

- [2026-07-05] Moving `skills/` → `ai/skills/` dangles the live
  `~/.claude/skills/*` symlinks, which breaks Skill-tool loading of
  repo-hosted skills (/feature, /iterate, /commit, /update-learnings)
  mid-migration. Harness denies manual repair of `~/.claude` links; they are
  fixed when `dot link` runs in the final feature. Until then, read
  `ai/skills/<name>/SKILL.md` directly and follow it inline.
  [RESOLVED 2026-07-05] Self-healing by design: live `dot link` on
  j-bakotsu-mbp repointed the links and Skill loading recovered mid-session.
- [2026-07-05] Plan acceptance criteria (§7) referenced
  `dotfiles/.config/emacs`, but the actual tool dir is `emacs-plus` — spec
  drift; verified against `emacs-plus`/`nvim` instead.
- [2026-07-05] Heredoc commit messages: `$HOME` in a quoted heredoc got
  over-escaped to a literal `\$HOME`, requiring `--amend`. Prefer single-quoted
  heredoc delimiters or `-m` with single quotes.

## Domain Knowledge

- [2026-07-05] `hosts/sf-cloud-ws/homedir/.npmrc` is a real git-tracked,
  host-specific file (Snowflake work registries) — NOT a symlink to core. In
  regeneration it must become a real file at `hosts/sf-cloud-ws/.npmrc`;
  sf-cloud-ws gets no `ai/` (it never had CLAUDE.md/skills).
- [2026-07-05] CGGK727W04 gets no `ai/` either (preserve no-AI state); its old
  `tmux` link was absolute under username `jzawrotny` — regeneration with
  relative links fixes it incidentally.
- [2026-07-05] `~/.claude/skills/` is a shared merge point: user skills +
  nix-managed matt-pocock skills (from `claude-mattpocock-skills.nix`). It must
  stay a real directory of per-item symlinks — never a directory symlink.
- [2026-07-05] `git log --follow` only follows renames for individual files,
  not directories — verify move history with a file path
  (e.g. `dotfiles/.config/nvim/bootstrap.lua`).

## Open Questions

## Consolidated Principles
