---
tags:
  - doom
  - knowledge
modified: 2026-09-26T13:59:09-04:00
---
# ghostel-copy-mode toggles, it doesn't just enter

`ghostel-copy-mode` (bound to `C-c C-t`, `lisp/ghostel.el`) checks
`ghostel--input-mode` itself: if already `'copy`, calling it again runs
`ghostel-readonly-exit` instead of re-entering copy-mode. So any code that
wants to *ensure* copy-mode (rather than toggle it) must check
`ghostel--input-mode` first and only call `ghostel-copy-mode` when it isn't
already `'copy` or `'emacs` — calling it unconditionally on an
already-copy-mode buffer silently kicks the buffer back into its prior
input mode, which looks like a no-op bug rather than a crash.

Ghostel's five input modes live in the buffer-local `ghostel--input-mode`:
`semi-char` (default, forwards keys to the PTY), `char`, `line`, `emacs`,
`copy`. Only `emacs` and `copy` make an Evil/Emacs region selection
meaningful — `ghostel--terminal-input-mode-p` (`semi-char`/`char`) and
`line` mode don't.

Source: `~/.config/emacs/.local/straight/repos/ghostel/lisp/ghostel.el`
(`ghostel-copy-mode`, `ghostel--input-mode`, `ghostel--terminal-input-mode-p`).
Relevant to `.system-vault/Projects/doom/ghostel-buffer-references/`.
