---
name: iterate
description:
  Use this skill when the user invokes /iterate or wants to run a task, prompt,
  or skill repeatedly in a subagent loop until a goal is reached. Trigger on
  "/iterate", "loop until done", "keep trying until X", "run this until tests
  pass", "retry until success", or any request to run something repeatedly until
  a defined outcome is achieved. Do NOT trigger for time-based recurrence (use
  /loop for that) or single-shot tasks.
---

# Iterate

Run a task in a subagent loop until a condition is met.

```
/iterate "<task or skill — include the exit criterion in the description>"
```

Example: `/iterate "run tests, identify failures, fix them, stop when all pass"`

## Loop

1. Spawn a subagent with the verbatim task, iteration number, and (iteration 2+)
   a brief handoff: what was tried, what happened, what remains. Instruct the
   subagent to signal `ITERATION_COMPLETE` on its own line when it believes the
   condition is met.
2. Verify the stop condition yourself — run the command or read the file; don't
   trust the subagent's report.
3. Report progress (what changed) and go back to step 1, or stop.

When done, summarize: iterations run, concrete change (e.g. "failures 12 → 0"),
which criterion triggered. If the condition wasn't met, say what remains and
suggest a next step.

## Guidelines

- **No exit criterion:** ask before starting rather than looping indefinitely.
- **Stuck:** if consecutive iterations show no progress, stop. Running as a
  nested subagent (`[called from: ...]` present)? Output a diagnostic and exit.
  Otherwise, surface the situation and ask how to proceed.
