---
vault_dir: ../../../.system-vault
---

# Project vault (doom)

This directory shares the repo-wide [Obsidian project vault](https://github.com/jaidetree/obsidian-project-vault) at `../../../.system-vault/` (repo root: `.system-vault/`). It is the home for knowledge notes, reference material, ADRs, and this directory's specs/issues.

**`vault_dir` above is the single source of truth for the vault's location from this directory.** Any skill working here reads it from here — never guess a path, and never hardcode `.doom-vault` (that name is retired).

## Layout

- `../../../.system-vault/Knowledge/` — standalone zettel notes, one per learning, flat (no subfolders). Written and recalled by `/knowledge`. **Tag every note about this doom config with `doom`** (frontmatter `tags: [doom]`) so it's filterable within the shared, multi-project vault.
- `../../../.system-vault/Library/` — reference material worth keeping alongside the code.
- `../../../.system-vault/Domain/`, `../../../.system-vault/ADRs/` — glossary and architectural decisions. See `domain.md`.
- `../../../.system-vault/Projects/doom/<project-name>/` — this directory's fixed `doom` namespace, one nested per-feature project dir per slug (e.g. `ghostel-buffer-references`). Never put specs/issues directly in `Projects/doom/` itself. See `issue-tracker.md`.
- `../../../.system-vault/Templates/` — note templates the vault's own skills copy from.

## If this file is absent

Fall back to the root `docs/agents/vault.md` and root `AGENTS.md` — the vault itself still exists at the repo root.
