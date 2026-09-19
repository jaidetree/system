---
vault_dir: .doom-vault
---

# Project vault

This repo has an [Obsidian project vault](https://github.com/jaidetree/obsidian-project-vault) at `.doom-vault/`. It is the home for knowledge notes, reference material, ADRs, and (optionally) issues.

**`vault_dir` above is the single source of truth for the vault's location.** Any skill that needs the vault reads it from here — never guess `vault/`, and never hardcode the name.

## Layout

- `.doom-vault/Knowledge/` — standalone zettel notes, one per learning, flat (no subfolders). Written and recalled by `/knowledge`.
- `.doom-vault/Library/` — reference material worth keeping alongside the code.
- `.doom-vault/Domain/`, `.doom-vault/ADRs/` — glossary and architectural decisions. See `domain.md`.
- `.doom-vault/Projects/<slug>/` — specs and issues, **only if** the vault is this repo's issue tracker. See `issue-tracker.md` (absent if it isn't).
- `.doom-vault/Templates/` — note templates the vault's own skills copy from.

## If this file is absent

The repo has no vault. Skills that require one (`/knowledge`, `/new-vault-project`) should tell the user to run `/setup-project-vault` and stop — never create a partial vault by hand.
