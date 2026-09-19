# AGENTS

Private `$DOOMDIR` for Doom Emacs. Part of the larger `system` dotfiles/nix
monorepo (see root `AGENTS.md`); this file covers only this directory.

## Files

- `init.el` — enabled Doom modules (the `doom!` block). Editing this requires
  `doom sync` + Emacs restart.
- `packages.el` — extra/overridden packages via `package!`. Also requires
  `doom sync` after changes.
- `config.el` — private config (theme, keybindings, functions, hooks).
  Changes take effect on Emacs restart alone; no `doom sync` needed.
- `config.local.el` — gitignored, machine-local overrides. Loaded from the
  end of `config.el` via `(load! "config.local" nil 'noerror)`. Use this for
  host-specific settings instead of editing `config.el`.
- `modules/` — private Doom modules (see below).

## The one command

After changing `packages.el` or `init.el`:

```
~/.config/emacs/bin/doom sync
```

then restart Emacs. If it fails, its output names the failing recipe/file —
fix that and rerun the same command. `config.el`-only changes need neither.

## Private modules (`modules/`)

- `modules/editor/lisp-state` — Spacemacs-style evil lisp state for
  structural sexp editing (vendored `jaidetree/evil-lisp-state` fork). See
  its `README.org` for the upstream undo-tree/toggle patches it carries and
  how to run its integration test.
- `modules/tools/claude-code` — MCP-based Claude Code integration
  (`claude-code-ide.el`), bound under `SPC o c`. See its `README.org` for
  prerequisites and the `claude-code-ide-cli-path` machine-local override
  pattern.

Each private module has its own `README.org`/`config.el`/`packages.el` —
read the module's README before changing its `config.el`.

## Conventions

- Enable/disable modules only in `init.el`; keep module flags (e.g.
  `+everywhere`, `+lsp`) next to the module name as Doom expects.
- Wrap package reconfiguration in `with-eval-after-load`, except for
  file/directory vars (e.g. `org-directory`) and `doom-`/`+`-prefixed
  variables, which must be set eagerly.
- Host-specific settings go in `config.local.el`, not `config.el`.
- Temporary upstream-bug workarounds in `config.el` are marked `;; TEMPORARY:`
  with a link to the upstream issue — remove them once fixed upstream.

## Agent skills

### Project vault

Shares the repo-wide vault at `../../../.system-vault/` (repo root:
`.system-vault/`), home for knowledge notes, ADRs, reference material. See
`docs/agents/vault.md`.

### Issue tracker

Fixed project slug `doom`: `../../../.system-vault/Projects/doom/`. New
specs/issues/features for this doom config always go there — never derive or
create a new slug for doom work. See `docs/agents/issue-tracker.md`.

### Knowledge tagging

Every knowledge note, issue, and spec about this doom config gets the `doom`
tag (frontmatter `tags: [doom]`, alongside any triage role tag), so doom
material is filterable within the shared, multi-project vault.

### Triage labels

Roles applied as frontmatter tags. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context, glossary at `../../../.system-vault/Domain/CONTEXT.md`, ADRs
at `../../../.system-vault/ADRs`. See `docs/agents/domain.md`.
