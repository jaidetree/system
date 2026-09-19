# Issue tracker: Obsidian project vault (doom)

This directory's project slug is **fixed: `doom`**. Issues and specs live as markdown at `../../../.system-vault/Projects/doom/`. Never derive or create a new slug for doom work — everything nests under this one project dir. A visual kanban board (Obsidian Bases `.base` file) renders them for humans; agents operate on the files directly.

## Conventions

- Spec: `../../../.system-vault/Projects/doom/Spec.md`.
- Issues/slices: `../../../.system-vault/Projects/doom/issues/<Status>/<NN>-<slug>.md`.
- **Dev state = the folder** the file sits in: `Backlog / Ready / In Progress / Review / Done / Archived`. Moving the file between these folders is the status change.
- **Triage role = frontmatter `tags:`** (e.g. `ready-for-agent`) — see `triage-labels.md`. Orthogonal to dev state. **Also tag every doom issue/spec/knowledge note `doom`.**
- **id = the filename** `NN-slug` (e.g. `03-setup-e2e-harness.md`), numbered from `01`.
- **Blocking** (frontmatter, wayfinder-ready): `blocked_by` / `blocks` are lists of relative markdown links to the issue files, e.g. `[02-api](<../Ready/02-api.md>)` (frontmatter-links plugin). **Resolve by filename stem, never the folder segment** — files move between folders, so the path in the link goes stale by design.
- **type** (frontmatter): `research | prototype | grilling | task`.

Issue body template: `../../../.system-vault/Templates/Issue Template.md` (Description / User Stories / Implementation Plan Overview / Acceptance Criteria).

## When a skill says "publish a spec" (or a PRD) for doom

The project already exists at `../../../.system-vault/Projects/doom/` — do not run `/new-vault-project` for a new slug. Write or update the spec content directly at `../../../.system-vault/Projects/doom/Spec.md`.

## When a skill says "publish an issue"

Create a new file in `../../../.system-vault/Projects/doom/issues/Backlog/` with a `ready-for-agent` tag (or the role instructed), plus the `doom` tag.

## When a skill says "fetch the relevant ticket"

Find the file by its `NN-slug` stem anywhere under `../../../.system-vault/Projects/doom/issues/` (its folder = current dev state). The user usually passes the number or stem.

## When a skill sets a triage state

Edit the `tags:` frontmatter only. Do **not** move the file between folders — dev state and triage role are independent.

## Dev-state transitions

Driven by `/slice` (which wraps `/implement`), not by triage:

- **Claim / start work**: move `Ready` → `In Progress`.
- **Finish**: move `In Progress` → `Review`. Only a human moves `Review` → `Done`.

## Frontier (wayfinder-ready)

Issues in `Ready/` whose every `blocked_by` stem resolves to a file now in `Done/`. Wired by the generated `/afk` skill, which ships the whole frontier per round and recomputes it after each merge.
