# Manual testing: ghostel-buffer-references

All three tickets are `Done`. This is the one human-testing entry point for
the whole feature — nothing per-ticket. See `Spec.md` for the full design.

**Before starting:** restart Emacs (or `M-x doom/reload`) so
`modules/tools/claude-code/config.el`'s `(load! "buffer-ref")` picks up the
new code. No `doom sync` needed — no `packages.el`/`init.el` changes were
made by any of the three tickets.

## [01 — Generic non-file-buffer reference](issues/Done/01-generic-non-file-buffer-reference.md)

1. Start a `claude-code-ide` session in a project (`SPC o c` → start).
2. Open any non-file buffer — e.g. `M-x eshell`, or `*Messages*`, or a
   `magit-status` buffer.
3. Select some text with an Evil visual selection.
4. Press `SPC o c i`. Confirm a reference chip appears in the Claude Code
   chat labeled with a temp-file path, and that the chat can see exactly the
   selected text (not the whole buffer).
5. Repeat from an ordinary file-backed buffer with a region selected —
   confirm behavior is identical to before (real file path, real line
   numbers, no change from pre-feature behavior).
6. In a non-file buffer with no selection, press `SPC o c i` — confirm
   nothing happens (no error, no chip, no temp file written).

## [02 — Ghostel copy-mode auto-switch](issues/Done/02-ghostel-copy-mode-auto-switch.md)

1. Open a ghostel terminal buffer running some command with visible output.
2. Confirm it's in default `semi-char` mode (`M-: ghostel--input-mode` shows
   `semi-char`).
3. Select a range of terminal output with Evil visual mode — the selection
   may look visually inert, since keys still forward to the PTY in
   semi-char mode.
4. Press `SPC o c i`. Expect: the buffer auto-switches to copy-mode, the
   intended text is selected, and a reference chip appears in the chat
   pointing at a temp file with exactly that captured text.
5. Repeat, but manually enter copy-mode first (`C-c C-t`) before selecting,
   then invoke `SPC o c i` again — confirm it does **not** toggle back out
   of copy-mode (no flicker/exit), and the reference is still created
   correctly.
6. Try from a ghostel buffer already in `emacs`-mode — same as step 5, no
   switch.
7. Try from a plain `eshell`/`shell-mode` buffer with a selection — confirm
   the reference still works exactly as in ticket 01, with no
   ghostel-related side effects (no attempted mode switch).

## [03 — Temp-file cleanup lifecycle](issues/Done/03-temp-file-cleanup-lifecycle.md)

1. In a ghostel/eshell buffer, select text and run `SPC o c i` a few times
   to create several temp files.
2. `M-: +claude-code-ide--temp-file-dir` to see the session's temp dir;
   `ls` it in a shell to confirm the files exist.
3. `M-: (+claude-code-ide--temp-file-sweep)` immediately — confirm nothing
   is deleted (all files are fresh, well under the 4-hour max age).
4. Backdate one file's mtime past the threshold, e.g.
   `M-: (set-file-times "<path>" (time-subtract (current-time) (seconds-to-time 18000)))`
   (5 hours), then re-run the sweep — confirm only that file is removed,
   and other fresh files are untouched.
5. Quit Emacs normally (`SPC q q`) and confirm the whole session temp
   directory is gone afterward.

## End-to-end pass

Since all three tickets touch the same dispatch path
(`+claude-code-ide-at-mentioned-for-buffer` in
`modules/tools/claude-code/buffer-ref.el`), do one combined run to catch
interaction effects the per-ticket steps above wouldn't surface:

1. Start a `claude-code-ide` session in a real project.
2. In a ghostel buffer (default semi-char mode) running a build or test
   command, select a chunk of output and `SPC o c i` — confirm the
   auto-switch to copy-mode happens, a correct reference chip appears, and
   the underlying temp file lands in the session's temp dir.
3. Immediately do the same from an ordinary code buffer, then from an
   `eshell` buffer — confirm all three reference kinds coexist correctly in
   the same chat session (each with its own correct file/label), and that
   the code-buffer reference is unaffected by any of the non-file-buffer
   machinery.
4. Let the buffer references pile up, then either wait ~30 minutes for the
   periodic sweep to run naturally (checking `ls` on the temp dir before and
   after) or manually invoke `+claude-code-ide--temp-file-sweep` after
   backdating a couple of files, to confirm cleanup coexists correctly with
   an active session (no in-flight reference ever gets swept).
5. Exit Emacs and confirm the session's temp directory is fully gone.

## Batch test coverage (already automated, not manual)

`modules/tools/claude-code/test/claude-code-buffer-ref-test.el` — run via
`emacs -Q --batch -l modules/tools/claude-code/test/claude-code-buffer-ref-test.el`
from the doom directory. Currently 22/22 checks passing, covering all three
tickets' dispatch logic with stubbed `claude-code-ide`/`ghostel` — this is
not a substitute for the live-session steps above, which are the only way to
verify real MCP wire behavior, real ghostel PTY behavior, and real CLI-side
chip rendering (all explicitly out of scope for the automated seam per
`Spec.md`).
