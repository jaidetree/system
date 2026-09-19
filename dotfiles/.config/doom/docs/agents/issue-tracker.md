# Issue tracker: Obsidian project vault (doom)

This directory's project namespace is **fixed: `doom`**. Every feature/spec
gets its own nested per-feature project dir under it:
`../../../.system-vault/Projects/doom/<project-name>/`. Never put specs or
issues directly in `Projects/doom/` itself — always create (via
`/new-vault-project`, passing slug `doom/<project-name>`) the nested
per-feature project dir first. A visual kanban board (Obsidian Bases `.base`
file) renders them for humans; agents operate on the files directly.

## Conventions

- Spec: `../../../.system-vault/Projects/doom/<project-name>/Spec.md`.
- Issues/slices: `../../../.system-vault/Projects/doom/<project-name>/issues/<Status>/<NN>-<slug>.md`.
- **Dev state = the folder** the file sits in: `Backlog / Ready / In Progress / Review / Done / Archived`. Moving the file between these folders is the status change.
- **Triage role = frontmatter `tags:`** (e.g. `ready-for-agent`) — see `triage-labels.md`. Orthogonal to dev state. **Also tag every doom issue/spec/knowledge note `doom`.**
- **id = the filename** `NN-slug` (e.g. `03-setup-e2e-harness.md`), numbered from `01`.
- **Blocking** (frontmatter, wayfinder-ready): `blocked_by` / `blocks` are lists of relative markdown links to the issue files, e.g. `[02-api](<../Ready/02-api.md>)` (frontmatter-links plugin). **Resolve by filename stem, never the folder segment** — files move between folders, so the path in the link goes stale by design.
- **type** (frontmatter): `research | prototype | grilling | task`.

Issue body template: `../../../.system-vault/Templates/Issue Template.md` (Description / User Stories / Implementation Plan Overview / Acceptance Criteria).

## When a skill says "publish a spec" (or a PRD) for doom

If the feature's per-feature project dir doesn't exist yet, run
`/new-vault-project` with slug `doom/<project-name>` to scaffold
`../../../.system-vault/Projects/doom/<project-name>/` first. Then write or
update the spec content at
`../../../.system-vault/Projects/doom/<project-name>/Spec.md`.

## When a skill says "publish an issue"

Create a new file in
`../../../.system-vault/Projects/doom/<project-name>/issues/Backlog/` with a
`ready-for-agent` tag (or the role instructed), plus the `doom` tag.

## When a skill says "fetch the relevant ticket"

Find the file by its `NN-slug` stem anywhere under
`../../../.system-vault/Projects/doom/<project-name>/issues/` (its folder =
current dev state). The user usually passes the number, stem, or
project-name.

## When a skill sets a triage state

Edit the `tags:` frontmatter only. Do **not** move the file between folders — dev state and triage role are independent.

## Dev-state transitions

Driven by `/slice` (which wraps `/implement`), not by triage:

- **Claim / start work**: move `Ready` → `In Progress`.
- **Finish**: move `In Progress` → `Review`. Only a human moves `Review` → `Done`.

## Frontier (wayfinder-ready)

Issues in `Ready/` whose every `blocked_by` stem resolves to a file now in `Done/`. Wired by the generated `/afk` skill, which ships the whole frontier per round and recomputes it after each merge.
