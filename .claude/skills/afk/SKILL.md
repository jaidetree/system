---
name: afk
description: >-
  Use this skill when the user invokes /afk or wants this doom config driven
  to completion unattended — work every AFK-ready ticket, one after another
  (parallelizing independent ones), until nothing is left to ship.
disable-model-invocation: true
---

# AFK

Drive this doom config to completion in one session: repeatedly find every
ticket ready to implement with no human input, ship each one all the way to
`Done`, and integrate the results — round after round — until none remain.
Manual testing happens once, at the very end, against a single project-wide
guide — never per ticket.

## The frontier

A ticket is **frontier** when it carries the `ready-for-agent` tag and every
`blocked_by` stem resolves to a file now in `.../Done/`. Compute it from
`.system-vault/Projects/doom/issues/Ready/`; only if `Ready/` holds
no frontier-eligible ticket, compute it from `Backlog/` instead. Frontier
tickets need nothing from a human — they're exactly what's safe to hand to
subagents in parallel, because none blocks another.

## Steps

1. Read a knowledge summary: `scan-knowledge.sh .system-vault/Knowledge` (from
   the `knowledge` skill); surface the most relevant points.
2. Compute the frontier (see above): `Ready/` first, `Backlog/` if `Ready/` is
   empty of frontier-eligible tickets.
3. **Empty frontier?**
   - `Backlog/` holds tickets not tagged `ready-for-agent`: they need
     `/triage` before they're workable. Report the count and stop.
   - `Backlog/` is also empty (or every remaining ticket there is blocked):
     the project is complete — **skip to step 8**.
4. **Dispatch the whole frontier in one message** — one subagent per ticket,
   each `isolation: worktree`. Parallel dispatch is safe precisely because
   frontier tickets don't block each other. Tell each subagent to, in its own
   isolated copy:
   1. Run `/slice <ticket>` end-to-end — this carries the ticket through
      `Review` and checks off the acceptance criteria that now hold.
   2. Where `/slice` would stop for a human, close the loop instead: re-read
      the ticket's acceptance criteria against the diff. Every box checked
      and a clean `doom sync` (when `init.el`/`packages.el` changed) plus a
      clean Emacs start is what stands in for human review here — move the
      ticket `Review` → `Done` and commit that move.
   3. Hand back the ticket name, its final state (`Done` or, if a box
      wouldn't check out, left in `Review` with why), and the manual-test
      steps `/slice` produced.
5. **Integrate, one ticket at a time, in dispatch order** as each subagent
   reports back: merge its worktree branch — commits and all, including the
   `Done` move — then re-run `doom sync` (if applicable) and confirm a clean
   Emacs start on the integration branch to catch what only shows up
   combined. A conflict is resolved with the `resolving-merge-conflicts`
   skill, never `--abort`. Delete the worktree once merged. Append the
   reported manual-test steps to a running project-wide list, keyed by
   ticket.
6. **Stragglers.** A ticket left in `Review` — acceptance criteria that
   wouldn't check out, a failing verify the subagent couldn't fix, or a HITL
   blocker hit mid-slice — is a straggler, not a retry target this round.
   Leave it there, add it to a running stragglers list with why, and move
   on; it still merges (step 5) so its diff isn't lost.
7. Recompute the frontier — merged tickets in `Done/` may unblock others —
   and **goto 4**.
8. **Write the manual testing guide.** One file,
   `.system-vault/Projects/doom/MANUAL-TESTING.md`: one section
   per `Done` ticket (name, link, its collected steps), plus a short
   end-to-end pass across the whole project if the tickets touch related
   surfaces. This is the human's only manual-testing entry point — nothing
   per-ticket. Commit it, then report: everything shipped to `Done`, the
   stragglers list, and a pointer to the guide.
