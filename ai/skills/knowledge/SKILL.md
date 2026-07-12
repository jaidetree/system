---
name: knowledge
description:
  Knowledge capture as standalone zettel notes in the project vault. Use when
  the user wants to record a learning or knowledge note ("record this", "log
  that we learned"), or to reconcile or prune knowledge notes. Other
  skills (e.g. /feature, /slice) may invoke this when finishing a task.
---

# Knowledge

One standalone zettel per learning in `vault/Knowledge/`. Each note's
`description` frontmatter is its recall hook, so the index is **generated from
the notes** — never hand-maintained.

## Recording

Requires `vault/` in the repo. If missing, tell the user to run
`setup-project-vault` and stop — never create a partial vault.

Only record knowledge that is specific, reusable across sessions, and not
already covered — scan first (see Recall) and, if covered, update that note
instead.

One learning = one note in flat `vault/Knowledge/` (no subfolders), Title Case
filename stating the insight, e.g. `Heredoc Commit Messages Escape HOME.md`:

```markdown
---
description: $HOME in quoted heredocs over-escapes; use single-quoted delimiters
tags: [mistake]
date: 2026-07-05
---

`$HOME` in a double-quoted heredoc commit message got over-escaped to a
literal `\$HOME`, requiring `--amend`.

**Apply:** single-quoted heredoc delimiters or `-m` with single quotes.

Related: [[Git Mv Reorg With Staged Files]]
```

- `tags` — one of: `pattern` (approach that worked), `mistake` (trap to avoid),
  `domain` (stable fact about codebase/APIs/business), `question` (unresolved;
  resolve later with a dated correction)
- Body: the standalone fact plus an **Apply:** line saying how to use it
- Wikilink related notes `[[Title]]` — links to not-yet-written notes are fine

Writing the note **is** the recording — its `description` is the recall hook, so
there is no index line to keep in sync. Give every note a `description`; a note
without one is effectively unrecallable.

First recording in a repo:

1. Copy `Knowledge.base` (next to this SKILL) to `vault/Knowledge/Knowledge.base`
   if absent — the human-facing live table (All + tag-filtered views), read
   straight from frontmatter.
2. Install the Session Protocol block below into the repo's `CLAUDE.md` (create
   it if absent; skip if the heading already exists).

## Recall

Two readers over the same frontmatter — pick by whether Obsidian is open:

- **Agent / headless (default):** `scan-knowledge.sh vault/Knowledge` (next to
  this SKILL) prints the `- [[Title]] — hook` index from each note's
  `description`. For a targeted question, `rg -i <term> vault/Knowledge`. Never
  depends on Obsidian running.
- **Human / live:** open `Knowledge.base` in Obsidian, or with Obsidian running
  `obsidian base:query path=vault/Knowledge/Knowledge.base view=All format=md`
  (`view=Mistakes|Patterns|Open Questions` to scope). CLI hits only the open
  vault, so it is never the agent recall path.

There is no `INDEX.md` to maintain. If a repo still has one, treat it as a stale
artifact — delete it or regenerate with `scan-knowledge.sh`.

## Maintenance

1. Merge duplicate notes into one, keeping wikilinks working
2. Supersede stale or wrong notes with a dated correction inside the note —
   never silently delete
3. Resolve `question` notes with a dated resolution
4. Show a summary of what changed

## Session Protocol block (for CLAUDE.md)

```markdown
## Session Protocol

At the start of each session:

1. Run scan-knowledge.sh vault/Knowledge (from the knowledge skill) to list hooks
2. Open only the notes relevant to the current task

At the end of each task or session:

1. Record new patterns, mistakes, domain knowledge, or open questions as
   standalone notes in vault/Knowledge/ via the knowledge skill
2. Never edit another note's history — correct with a dated note
```
