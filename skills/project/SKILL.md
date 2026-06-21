---
name: project
description:
  Use this skill when the user invokes /project or wants to build out an entire
  project or multi-feature spec end-to-end. Trigger on "/project", "build this
  project", "implement the spec", "work through all the features in", or when a
  user hands over a spec file or project description and wants it fully
  implemented feature by feature.
---

# Project

Build a spec out feature by feature, using `/feature` (via `/iterate`) for each
one.

## Steps

1. Read `LEARNINGS.md` if it exists; note the most relevant points.
2. Read the spec. Ask focused questions to fill any gaps before proceeding.
3. Order features: hard dependencies first, foundational before derived,
   lower-risk before higher-risk. Note deps per feature, present the list, and
   wait for confirmation.
4. For each feature, run in the current (parent) context:

   ```
   /iterate --until "<success criteria>" "[called from: project] /feature <feature name>

   Description: <what it does>
   Constraints: <relevant constraints from spec>
   Success criteria: <verifiable by running a command or reading a file>"
   ```

5. After each feature completes, run `/update-learnings`. Prune when the file
   grows large.
6. When the loop ends, summarize: what was built, all commit hashes, spec drift,
   and anything skipped or abandoned with the reason.

## Guidelines

- **Agent tool is parent-only.** `/feature` subagents run as leaves — they
  cannot spawn further agents. All `/iterate` calls happen here.
- **Signal contract.** Each `/feature` leaf outputs `FEATURE_COMPLETE` or
  `FEATURE_INCOMPLETE: <handoff>`. `/iterate` independently verifies success
  criteria before stopping.
- **Parallel runs.** Two features may run in parallel only if neither depends on
  the other AND they touch clearly separate parts of the codebase. When
  uncertain, run sequentially.
- **Failures.** Surface failures before continuing — later features may depend
  on incomplete work. Check dirty state (`git status`) and offer skip, retry, or
  stop. If consecutive features fail without progress, stop and diagnose before
  proceeding.
