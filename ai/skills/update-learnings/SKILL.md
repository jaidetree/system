---
name: update-learnings
description:
  Use this skill when the user invokes /update-learnings, wants to record a
  project learning, initialize a LEARNINGS.md file, update the learning log,
  prune old learnings, or maintain a session memory across Claude conversations.
  Trigger when user says "record this", "log that we learned", "add to
  learnings", "update learnings", "initialize learnings", or "prune learnings".
---

# Update Learnings

Maintain a `LEARNINGS.md` file capturing project-specific knowledge across
sessions.

## Recording

If `LEARNINGS.md` doesn't exist, create it from the template below and add the
Session Protocol block to `CLAUDE.md` (creating it if absent, skipping if the
heading already exists).

Append `- [YYYY-MM-DD] <entry>` to the right section:

| Section                 | Use for                                                       |
| ----------------------- | ------------------------------------------------------------- |
| Patterns That Work      | Approaches that produced good results                         |
| Mistakes to Avoid       | What went wrong; traps to avoid                               |
| Domain Knowledge        | Stable facts about the codebase, APIs, or business logic      |
| Open Questions          | Unresolved things. Mark resolved ones `[RESOLVED YYYY-MM-DD]` |
| Consolidated Principles | Only written during pruning                                   |

Only record entries that are specific, reusable across sessions, and not already
covered.

## Pruning

1. Remove outdated, superseded, or resolved entries (keep resolved Open
   Questions only if they document a non-obvious path to resolution)
2. Merge duplicates — note "consolidated from N entries", keep most recent date
3. Synthesize recurring patterns into **Consolidated Principles**
4. Flag ambiguous entries `[REVIEW NEEDED]` rather than deleting
5. Preserve all five section headers even if empty
6. Rewrite the file and show a diff of what changed

---

## LEARNINGS.md template

```markdown
# Project Learnings

## Patterns That Work

## Mistakes to Avoid

## Domain Knowledge

## Open Questions

## Consolidated Principles
```

## Session Protocol block (append to CLAUDE.md)

```markdown
## Session Protocol

At the start of each session:

1. Read LEARNINGS.md
2. Briefly summarize what you've loaded from it so I know it's been processed

At the end of each task or session:

1. Identify any new patterns, mistakes, or domain knowledge worth recording
2. Append entries to the appropriate sections of LEARNINGS.md
3. Do not overwrite existing entries — only append, or correct with a dated note
```
