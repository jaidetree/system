---
name: commit
description:
  Create a detailed git commit with a conventional summary line and an extended
  decision-record body. Use when the user invokes /commit, says "commit this",
  "commit my changes", "record this work", or when another skill (e.g. /feature)
  needs to commit completed work. Produces commits that serve as durable context
  for future agents and humans reading git log.
---

# Commit

Stage relevant files and commit with a conventional summary line and a
decision-record body. Use `--amend` only when HEAD was created in this session
and not yet pushed.

## Message format

Summary: `<type>(<scope>): <description>` — imperative mood, max 72 chars.

Body (past tense, 80-char wrap) — include only sections that add value:

- **What changed** — concrete changes made
- **Why** — motivation and problem solved
- **Decisions** — design choices, alternatives considered, trade-offs accepted
  (most valuable)
- **Notes** — edge cases, follow-up work, deferred findings from `/review`
- **Resources** — links or ticket numbers, only if they exist

Trailers: `Refs: #123`, `BREAKING CHANGE: ...`, `Co-authored-by: ...` as
applicable.

## After committing

Delete `REVIEW.md` from the project root if it exists — it's a transient
`/review` artifact and must not be checked in.

## When called from another skill

Operate non-interactively. Include any advisory findings from `/review` in
Notes. Output the hash on its own line: `COMMIT: <hash>`
