---
name: slice
description: >-
  Use this skill when the user invokes /slice or wants to take one tracked
  vertical slice end-to-end: move it to In Progress, implement it, commit, and
  move it to Review. Trigger on "/slice <issue>", "do slice N", "work issue N",
  or "ship slice N".
---

# Slice

Take one tracked slice of this doom config end-to-end: In Progress → implement →
commit → Review.

Requires an issue argument (a `NN-slug` stem or number). Resolve it under
`.system-vault/Projects/doom/issues/**` by filename stem (zero-pad numbers to
two digits) — the folder it sits in is its current dev state. If no argument, or
the target is ambiguous, stop and ask.

## Steps

1. Read a knowledge summary: `scan-knowledge.sh .system-vault/Knowledge` (from
   the `knowledge` skill); surface the most relevant points.
2. Read the slice file, plus its spec (`.system-vault/Projects/doom/Spec.md`),
   `.system-vault/Domain/CONTEXT.md`, and any `.system-vault/ADRs` it touches. Stop if the issue isn't
   found — report what failed.
3. Move the slice file (from `Ready` or, if `/afk` dispatched it straight from
   `Backlog`, from `Backlog`) → `In Progress` (folder = dev state; see
   `docs/agents/issue-tracker.md`).
4. `/implement` the slice as specified. Follow project conventions: enable or
   disable modules only in `init.el`; wrap package reconfiguration in
   `with-eval-after-load` except for file/directory vars (e.g.
   `org-directory`) and `doom-`/`+`-prefixed variables, which are set eagerly;
   host-specific settings go in `config.local.el`, never `config.el`; each
   private module keeps its own `README.org`/`config.el`/`packages.el` under
   `modules/<category>/<name>/`. Write/update the module's own README (and its
   integration test, if it has one — e.g. `modules/editor/lisp-state`'s) at
   the seams the issue names.
5. Verify: run `~/.config/emacs/bin/doom sync` if `init.el` or `packages.el`
   changed (its output names any failing recipe/file — fix and rerun), then
   confirm Emacs starts cleanly with no errors/warnings on the modified
   surface, plus any module's own integration test when one exists (e.g.
   `modules/editor/lisp-state`'s README-documented test). On failure, fix and
   **goto 4**.
6. Commit: `/commit <slice description>`. Skip if nothing to commit; never
   commit partial or failing work.
7. Move the slice file `In Progress` → `Review` — this signals it awaits human
   testing. Check off the acceptance-criteria `- [ ]` boxes that now hold. Only
   a human moves it to `Done`.
8. Run `/knowledge` to record findings — what worked, what broke, and
   non-obvious domain facts — as notes in `.system-vault/Knowledge/`. Be
   selective.
9. Report a list of manual testing steps for humans.
