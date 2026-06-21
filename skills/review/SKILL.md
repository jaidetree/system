---
name: review
description:
  Self-review code changes for correctness, security, and quality before
  committing. Use when the user invokes /review, says "review my changes",
  "check this before I commit", "self-review", or when another skill (e.g.
  /feature) needs a pre-commit review pass. Produces tiered findings (critical
  vs advisory) and writes a persistent REVIEW.md.
---

# Review

Review the diff for issues. Classify each as **critical** (would cause bugs,
security holes, data loss, or break callers) or **advisory** (everything else).
When unsure, classify advisory.

Write findings to `REVIEW.md` in the project root — skip if clean, overwrite if
it exists:

```markdown
# Code Review

Reviewed: <YYYY-MM-DD>, <short description> Verdict: <PASS | BLOCKED | ADVISORY>

## Critical Issues

- [ ] **[<category>]** <location> — <what's wrong>. Fix: <suggestion>.

## Advisory

- **[<category>]** <location> — <what's wrong>. Consider: <suggestion>.

## Context Loaded

- <what was read>
```

Omit sections with no entries.

Then output one of:

- `REVIEW_PASS` — no findings.
- `REVIEW_ADVISORY: <N> suggestion(s), no blocking issues` — commit can proceed;
  pass findings to `/commit` for the Notes section.
- `REVIEW_BLOCKED: <N> critical issue(s)` — fix before committing, details in
  `REVIEW.md`.

If invoked with `[called from: ...]`, stop after the signal. Otherwise present
findings and offer to fix critical issues via `/iterate`.
