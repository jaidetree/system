---
tags: [ready-for-agent, doom]
type: task
blocked_by: []
blocks:
  - "[02-ghostel-copy-mode-auto-switch](<../Backlog/02-ghostel-copy-mode-auto-switch.md>)"
  - "[03-temp-file-cleanup-lifecycle](<../Backlog/03-temp-file-cleanup-lifecycle.md>)"
---
# Generic non-file-buffer reference support

## Description

`SPC o c i` (`claude-code-ide-insert-at-mentioned`) sends an empty file path
when invoked from a buffer with no `buffer-file-name` (terminals, eshell,
shell-mode, magit buffers, `*Messages*`, etc.), so the resulting reference is
useless to the agent. Add a dispatch step so that when the current buffer has
no `buffer-file-name` and has an active region, the selected text is captured
immediately (`buffer-substring-no-properties`), written to a labeled temp
file, and handed to the **existing, unmodified**
`claude-code-ide-mcp-send-at-mentioned` as if that temp file were the
buffer's real file (visit the temp file, select its whole contents, invoke
the send function with that buffer current). File-backed buffers must
continue to behave exactly as today — this is purely additive. No changes to
the vendored `claude-code-ide-mcp.el` / `claude-code-ide-mcp-handlers.el`.

See `../../Spec.md` for full context and the rejected protocol-level
alternative.

## User Stories

- A Doom Emacs user should be able to select text in a non-file-backed
  buffer (eshell, shell-mode, magit, `*Messages*`, or any other buffer
  without a backing file) and press `SPC o c i` to get a real reference chip
  in the Claude Code chat, the same as from a code buffer.
- A user should be able to keep using `SPC o c i` from an ordinary
  file-backed buffer with zero change in behavior.
- A user invoking `SPC o c i` in a non-file buffer with no active region
  should see it no-op (or a clear message) rather than sending an empty or
  nonsensical reference.
- A user should be able to tell which buffer a reference came from, since
  the temp file is named from the source buffer's name plus a timestamp.

## Implementation Plan Overview

- Add a dispatch function (e.g. `+claude-code-ide-at-mentioned-for-buffer`)
  that checks `(and (not (buffer-file-name)) (use-region-p))` and, when true,
  captures the region text, writes it to a temp file in a session-scoped
  temp directory (filename from buffer name + timestamp), visits that temp
  file, selects its whole contents, and calls the existing
  `claude-code-ide-mcp-send-at-mentioned` unmodified with that buffer
  current.
- Advise/wrap `claude-code-ide-insert-at-mentioned` (or the underlying send
  function) so `SPC o c i` dispatches through this new function first,
  falling through unchanged to today's behavior for file-backed buffers or
  buffers with no active region.
- Add a new batch-test file under `modules/tools/claude-code/test/`,
  following the pattern in
  `modules/editor/lisp-state/test/lisp-state-test.el` (batch Emacs script,
  stubbed dependencies, list of `(description . boolean)` assertions).

## Acceptance Criteria

- [ ] Invoking the reference command in a file-backed buffer with a region
      calls the original send function unchanged, with no temp file
      created.
- [ ] Invoking it in a simulated non-file buffer (no `buffer-file-name`)
      with an active region creates a temp file containing exactly the
      captured region text, named from the buffer name plus a timestamp,
      and calls the send function with that temp file as the effective
      file path spanning its whole contents.
- [ ] Invoking it in a non-file buffer with no active region creates no
      temp file and does not call the send function.
- [ ] A batch test file exists under `modules/tools/claude-code/test/` and
      passes, covering all three cases above.
