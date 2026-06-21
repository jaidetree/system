---
name: feature
description: >-
  Use this skill when the user invokes /feature or wants to implement a specific
  feature end-to-end: from understanding requirements through implementation,
  testing, and committing. Trigger on "/feature", "implement this feature",
  "build [feature name]", "add [capability] to the project", or when the user
  points at a section of a spec or task file and asks for it to be built.
---

# Feature

Implement a feature end-to-end: understand, implement, test, iterate, commit,
record learnings.

**Execution context:** If your invocation prompt contains `[called from: ...]`,
you're in leaf mode — work in a single pass, no subagents. Otherwise you're in
orchestrator mode — spawn subagents normally.

## Steps

### 1. Load context

Read `LEARNINGS.md` if it exists and surface the most relevant points. Check
`CLAUDE.md` for useful domain context.

### 2. Understand the feature

Read the description or referenced spec section (e.g.,
`docs/spec.md#authentication`). Stop if the file or anchor isn't found — report
exactly what failed. Ask one focused round of questions to establish what the
feature should do, what it should not do, and how to know it's done. Success
criteria must be verifiable by running a command or reading a file. If the user
can't supply them, propose criteria and get explicit agreement before
proceeding.

### 3. Plan (if requested or non-trivial)

Write out the approach, key decisions, files to change, and how it will be
tested. Wait for approval before proceeding. In leaf mode, proceed without
waiting.

### 4. Implement

**Leaf mode:** Read existing test patterns, implement, write/update tests, run
tests and lint, fix failures. Output one of:

```
FEATURE_COMPLETE
FEATURE_INCOMPLETE: <one sentence: what was done, what remains>
```

Proceed to steps 5–7 only on `FEATURE_COMPLETE`. Do not commit partial work.

**Orchestrator mode:** Run:

```
/iterate --until "<success criteria>" "[called from: feature] implement the feature, write tests, run tests and lint, fix failures"
```

Embed any approved plan summary in the task prompt. If the loop ends without
meeting criteria, surface the blocker and ask whether to continue, change
approach, or abandon.

### 5. Review

**Leaf mode:** Check the diff inline. If critical issues are found, output
`FEATURE_INCOMPLETE: review found N critical issues — <summary>` and stop.

**Orchestrator mode:** Run `/review <feature>`. On `REVIEW_PASS` or
`REVIEW_ADVISORY`, proceed (pass advisory findings to `/commit`). On
`REVIEW_BLOCKED`, offer to fix the issues or let the user override — do not
auto-commit.

### 6. Commit

Run `git status`. Skip if nothing to commit; do not commit partial work or
failing tests. Note any unrelated changes so `/commit` can exclude them. Then:

```
/commit <feature description>
```

### 7. Record learnings

Run `/update-learnings` to capture what worked, what went wrong, and any
non-obvious domain facts. Be selective.
