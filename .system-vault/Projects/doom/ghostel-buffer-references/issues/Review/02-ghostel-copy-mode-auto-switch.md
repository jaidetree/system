---
tags: [ready-for-agent, doom]
type: task
blocked_by:
  - "[01-generic-non-file-buffer-reference](<../Backlog/01-generic-non-file-buffer-reference.md>)"
blocks: []
---
# Ghostel copy-mode auto-switch

## Description

Ghostel's default input mode (semi-char) forwards nearly all keystrokes
straight to the underlying PTY, so an Evil visual-mode region in a ghostel
buffer is inert unless the buffer is already in copy-mode or emacs-mode (two
of ghostel's five input modes). Building on the generic non-file dispatch
from `01-generic-non-file-buffer-reference`, add a ghostel-specific step: if
the current buffer is derived from `ghostel-mode` and is not already in
copy-mode or emacs-mode when `SPC o c i` is invoked, switch it into copy-mode
first, then proceed with the region capture. Ghostel buffers already in
copy-mode/emacs-mode must not be switched again. This step must not apply to
non-ghostel non-file buffers (eshell, shell-mode, etc.), which have no such
input-mode concept.

See `../../Spec.md` for full context.

## User Stories

- A user invoking `SPC o c i` in a ghostel buffer that's still in its
  default semi-char mode should have it auto-switch to copy-mode so their
  visual selection is respected, without having to remember to switch modes
  manually first.
- A user invoking `SPC o c i` in a ghostel buffer already in copy-mode or
  emacs-mode should have their existing selection used as-is, with no
  redundant mode switch.
- A user working in a non-ghostel non-file buffer should see no
  ghostel-specific mode-switching behavior at all.

## Implementation Plan Overview

- Extend the dispatch function from `01-generic-non-file-buffer-reference`
  with a ghostel-specific pre-step: when `(derived-mode-p 'ghostel-mode)`
  (or equivalent) and the buffer is not already in a selection-capable input
  mode, invoke ghostel's copy-mode switch before reading the region.
- Add tests to the same batch-test file covering: ghostel buffer not in
  copy-mode (switch triggered), ghostel buffer already in copy-mode/
  emacs-mode (no redundant switch), and a non-ghostel non-file buffer (no
  mode-switch attempted at all).

## Acceptance Criteria

- [x] A simulated ghostel buffer not in copy-mode/emacs-mode has its mode
      switched to copy-mode before the region is captured.
- [x] A simulated ghostel buffer already in copy-mode or emacs-mode is not
      switched again.
- [x] A simulated non-ghostel non-file buffer (e.g. eshell/shell-mode) never
      triggers the ghostel mode-switch logic.
- [x] The batch test file covers all three cases and passes.
