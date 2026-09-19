---
tags: [ready-for-agent, doom]
type: task
blocked_by:
  - "[01-generic-non-file-buffer-reference](<../Backlog/01-generic-non-file-buffer-reference.md>)"
blocks: []
---
# Temp-file cleanup lifecycle

## Description

The temp files created by `01-generic-non-file-buffer-reference`'s dispatch
path (one per non-file-buffer reference, in a session-scoped temp directory,
named from the source buffer plus a timestamp) currently have no cleanup —
they'd accumulate indefinitely. Add automatic cleanup: remove them on Emacs
exit and/or via a periodic sweep, so the temp directory doesn't grow
unbounded across sessions.

See `../../Spec.md` for full context.

## User Stories

- A user should not see reference temp files accumulate indefinitely on
  disk across Emacs sessions.
- A user should be able to trust that these files are genuinely throwaway —
  removed automatically rather than requiring manual cleanup.

## Implementation Plan Overview

- Add a cleanup mechanism for the session-scoped temp directory used by
  `01-generic-non-file-buffer-reference` — e.g. a `kill-emacs-hook` that
  removes the directory/its contents, and/or a periodic sweep of files older
  than some threshold.
- Add a test to the same batch-test file verifying that stale temp files are
  actually removed by the cleanup mechanism.

## Acceptance Criteria

- [x] Temp reference files are removed when Emacs exits, and/or by a
      periodic sweep, without requiring manual intervention.
- [x] A test exists that creates a stale temp file and verifies the cleanup
      mechanism removes it.
- [x] Cleanup does not interfere with a reference temp file that is still
      pending being read/sent (no premature deletion of an in-flight
      reference).
