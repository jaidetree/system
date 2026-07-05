---
name: knowledge
description:
  Knowledge capture as standalone zettel notes in the project vault. Use when
  the user wants to record a learning or knowledge note ("record this", "log
  that we learned"), or to reconcile or prune the knowledge index. Other
  skills (e.g. /feature, /slice) may invoke this when finishing a task.
---

# Knowledge

One standalone zettel per learning in `vault/Knowledge/`, recalled via a small
index instead of one big file.

## Recording

Requires `vault/` in the repo. If missing, tell the user to run
`setup-project-vault` and stop — never create a partial vault.

Only record knowledge that is specific, reusable across sessions, and not
already covered — check `INDEX.md` first; if covered, update that note instead.

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

Then append to `vault/Knowledge/INDEX.md` (create if absent) one line:
`- [[Note Title]] — <one-line hook>`. The index is the only file read at
session start; never put note bodies in it. A note without an index line is
unrecallable — recording is complete only when both note and index line exist.

First recording in a repo: install the Session Protocol block below into the
repo's `CLAUDE.md` (create it if absent; skip if the heading already exists).

## Maintenance

1. Reconcile `INDEX.md` against the directory both ways: add lines for
   hand-written notes missing from the index, remove lines whose notes are gone
2. Merge duplicate notes into one, keeping wikilinks working
3. Supersede stale or wrong notes with a dated correction inside the note —
   never silently delete
4. Resolve `question` notes with a dated resolution
5. Show a summary of what changed

## Session Protocol block (for CLAUDE.md)

```markdown
## Session Protocol

At the start of each session:

1. Read vault/Knowledge/INDEX.md
2. Open only the notes relevant to the current task

At the end of each task or session:

1. Record new patterns, mistakes, domain knowledge, or open questions as
   standalone notes in vault/Knowledge/ via the knowledge skill
2. Never edit another note's history — correct with a dated note
```
