---
tags: [doom, ready-for-agent]
---

# Spec

## Problem Statement

`SPC o c i` (`claude-code-ide-insert-at-mentioned`) lets you select text in a
code buffer and reference it in the running Claude Code chat session — a
feature the user relies on constantly and misses badly whenever it doesn't
work. It silently fails to do anything useful in a **ghostel** buffer (the
Doom-integrated terminal emulator, powered by libghostty-vt, that also
renders the Claude Code chat window itself): the command sends the CLI a
reference with an empty file path, because `claude-code-ide`'s reference
mechanism is built entirely around `buffer-file-name`, and a ghostel buffer
— like any terminal, eshell, or other non-file-backed buffer — has none. The
user can select terminal output (build logs, command output, another
terminal pane) perfectly well with Evil visual mode; there's just no way to
turn that selection into something the agent can see.

## Solution

Extend the existing `SPC o c i` reference command so it also works from any
buffer that has no backing file, not just ghostel specifically. When
invoked with an active region in such a buffer, the selected text is
captured immediately, written to a throwaway temp file, and handed to
`claude-code-ide`'s **existing, unmodified** reference-sending function as if
that temp file were the buffer's real file — producing a proper reference
chip in the chat UI exactly like a code-buffer reference does, with no
patches to the vendored `claude-code-ide` package required. For ghostel
buffers specifically, if the buffer isn't already in a selection-capable
mode (copy-mode/emacs-mode) when the command is invoked, it's switched into
copy-mode automatically first, since ghostel's default mode forwards
keystrokes straight to the PTY and Evil selection is otherwise inert there.

## User Stories

1. As a Doom Emacs user running Claude Code via `claude-code-ide`, I want to select a range of terminal output in a ghostel buffer and reference it with `SPC o c i`, so that I can point the agent at a build error, log line, or command output without retyping it.
2. As that user, I want the same `SPC o c i` keybinding to work whether I'm in a code buffer or a terminal buffer, so that I don't need to learn or remember a second command.
3. As that user, I want the reference to appear in the chat UI as a proper reference chip (not a raw pasted blob dumped into my message), so that terminal-sourced references look and behave the same as code-buffer references.
4. As that user, invoking the reference command in a ghostel buffer that's still in its default semi-char input mode, I want it to automatically switch into copy-mode so my visual selection is respected, so that I don't have to remember to switch modes manually before every reference.
5. As that user, if I invoke the reference command in a ghostel buffer that's already in copy-mode or emacs-mode, I want it to just use my existing selection without changing modes again, so that the command doesn't disrupt a selection I've already carefully made.
6. As that user, I want the referenced text to be exactly what I selected at the moment I invoked the command, so that if the terminal's scrollback later scrolls, gets cleared, or evicts old lines (ghostel's 5MB scrollback ring buffer deletes evicted lines from the buffer outright), my reference is unaffected.
7. As that user, I want this to also work from other non-file-backed buffers I might select text in (eshell, `shell-mode`, `magit` buffers, `*Messages*`, etc.), so that the fix isn't narrowly special-cased to ghostel and covers the whole class of "buffer with no file" problems.
8. As that user, I want buffers that already have a real file (ordinary code buffers) to keep behaving exactly as they do today, with zero behavior change, so that this fix is additive and doesn't regress the working case.
9. As that user, I want each terminal-sourced reference identified by the source ghostel buffer's name (e.g. `*ghostel: npm run build*`), so that when I later look at what was referenced, I can tell which terminal/command it came from.
10. As that user, I want the temp files created for these references to be cleaned up automatically (on Emacs exit, or via a periodic sweep) rather than accumulating indefinitely, so that my filesystem doesn't fill up with throwaway reference snapshots.
11. As that user, I do not want a `selection_changed`-style live/passive reference to fire continuously as I move around a ghostel buffer, so that a temp file isn't written on every cursor movement — I only want a reference created when I explicitly invoke the command.
12. As that user, if I invoke the reference command in a non-file buffer with no active region, I want it to behave sensibly (e.g. no-op or a clear message), so that the command doesn't error or produce a nonsensical empty reference.
13. As that user, I want this to be implemented as an addition to my own Doom private config, not as a fork of the vendored `claude-code-ide` package's CLI-facing tool-call handling, so that the fix survives upstream package updates without needing to be re-patched.

## Implementation Decisions

- **Trigger point**: advise (or wrap) `claude-code-ide-insert-at-mentioned` / its underlying `claude-code-ide-mcp-send-at-mentioned`, so `SPC o c i` remains the single entry point for both file-backed and non-file-backed buffers. No new keybinding.
- **Dispatch condition**: when the current buffer has no `buffer-file-name` and `use-region-p` is true, divert to the new non-file path described below; otherwise fall through unchanged to the existing, unmodified behavior. This makes the fix general to any non-file-backed buffer (ghostel, eshell, `shell-mode`, magit, etc.), not ghostel-specific.
- **Ghostel mode handling**: when the current buffer is derived from `ghostel-mode` (or equivalent) and is not already in a selection-capable input mode (copy-mode or emacs-mode, per ghostel's five input modes: semi-char, char, line, emacs, copy), switch it into copy-mode before reading the region. This step is skipped for non-ghostel non-file buffers, which don't have this input-mode concept.
- **Capture timing**: eager. The region's text (`buffer-substring-no-properties`) is read immediately when the command is invoked, not lazily re-read later. This decision is driven directly by ghostel's scrollback behavior: `ghostel-max-scrollback` (default 5MB / ~5,000 rows at 80 cols) is enforced as a true ring buffer, and eviction genuinely deletes old rows from the Emacs buffer text (not just from the native libghostty-vt engine's internal state) — so a lazy pointer resolved later could point at text that's already gone.
- **Delivery mechanism**: write the captured text to a temp file in a session-scoped temp directory, filename derived from the source buffer's name plus a timestamp. Then reuse `claude-code-ide-mcp-send-at-mentioned` **completely unmodified** by making it operate against that temp file: find/visit the temp file in a buffer, select its entire contents as the active region, and invoke the existing send function with that buffer current (so its own `(or (buffer-file-name) "")` lookup naturally resolves to the temp file's real path, and its own region/line-number computation naturally spans the whole temp file). No patches to `claude-code-ide-mcp.el` / `claude-code-ide-mcp-handlers.el` (the vendored, hardcoded, CLI-facing tool/notification code) are needed or wanted.
- **Rejected alternative — protocol-level buffer mention**: an earlier design considered adding a new MCP tool (e.g. `readBuffer`) that the CLI could call to lazily fetch buffer content on demand, paired with a marker syntax typed into the chat input. Rejected because: (a) the live-session, CLI-facing tool list is hardcoded at load time in the vendored `claude-code-ide-mcp-handlers.el`/`claude-code-ide-mcp.el` — the package's own user-extensible tool mechanism (`claude-code-ide-make-tool` / `claude-code-ide-mcp-server-tools`) only feeds a separate, unrelated HTTP-based MCP server, not the WebSocket session the CLI actually uses — so this would require patching vendored, upstream-update-fragile code; and (b) ghostel's scrollback eviction (above) means a lazy re-read is unsound anyway for terminal content.
- **Label**: the source ghostel/terminal buffer's Emacs buffer name (e.g. `*ghostel: npm run build*`) is the identifying label, used to build the temp filename. No additional metadata/bookkeeping beyond that.
- **Scope**: general to any buffer without `buffer-file-name`, gated purely on that condition — not a ghostel-specific special case (only the copy-mode auto-switch step is ghostel-specific).
- **Passive tracking**: explicitly out — no `selection_changed`-equivalent live tracking is added for non-file buffers. Only the explicit, on-demand `SPC o c i` command participates.
- **No active region**: if the command is invoked in a non-file buffer with no active region, it should not attempt to create an empty/nonsensical reference (no-op or a clear user-facing message — exact UX left to implementation, not a hard requirement of this spec).
- **Temp file lifecycle**: temp files live in a session-scoped temp directory (e.g. under `temporary-file-directory`) and are cleaned up on Emacs exit or via a periodic sweep — not retained indefinitely.
- **Placement**: implemented as an addition within this private Doom config (e.g. `modules/tools/claude-code/`), not as a modification to the vendored `claude-code-ide` package source, consistent with this repo's existing pattern of shadowing/advising third-party functions from `config.el` rather than patching vendored files directly (cf. the existing `+ghostel--buffer-name` / `+ghostel/toggle` shadows).

## Testing Decisions

- **Seam**: a single pure dispatch function is the one thing under test — something like `+claude-code-ide-at-mentioned-for-buffer`, which takes "does the current buffer have a `buffer-file-name`, is there an active region" and decides whether to fall through to the original behavior or divert into the temp-file path, and (for ghostel buffers) whether a copy-mode switch is needed first. Good tests here assert observable outcomes (temp file exists with the right content, the original send function was invoked with the right effective file path/region, mode-switch happened or didn't) rather than internal call sequencing.
- **Prior art**: `modules/editor/lisp-state/test/lisp-state-test.el` — a batch-mode Emacs script (`emacs -Q --batch -l <file>`) that stubs out heavy dependencies (there, `doom-modeline`; here, the parts of `claude-code-ide`/`ghostel` not under test), loads the real config code, and asserts a list of `(description . boolean)` checks. The new test should follow this exact pattern: a batch script under a new `modules/tools/claude-code/test/` directory, stubbing `claude-code-ide-mcp-send-at-mentioned` (or capturing its arguments) and `ghostel`-mode predicates rather than requiring a live MCP session, a real ghostel process, or network access.
- **What to test**:
  - File-backed buffer with a region: falls through unchanged — the original send function is called with the real buffer's own file path/region, and no temp file is created.
  - Non-file buffer (simulated, no `buffer-file-name`) with an active region: a temp file is created containing exactly the captured region text, named from the buffer name + timestamp, and the send function is invoked with that temp file as the effective file path spanning the whole file.
  - Ghostel buffer not in copy-mode: the copy-mode switch is triggered before capture.
  - Ghostel buffer already in copy-mode/emacs-mode: no redundant mode switch.
  - Non-ghostel non-file buffer (e.g. simulated eshell/shell-mode): temp-file path is taken with no attempt at a copy-mode switch (that step is ghostel-specific).
  - Non-file buffer with no active region: no temp file is created, no send is attempted.
- **Not tested here**: real MCP/WebSocket wire behavior, real ghostel PTY/native-module behavior, real CLI-side rendering of the reference chip — these are exercised only manually against a live session, not in the batch test suite.

## Out of Scope

- Passive/automatic `selection_changed`-style tracking for non-file buffers.
- Any change to the vendored `claude-code-ide` package's CLI-facing WebSocket tool/notification handling (`claude-code-ide-mcp.el`, `claude-code-ide-mcp-handlers.el`).
- A protocol-level "lazy buffer mention" mechanism resolved at send time (considered and rejected — see Implementation Decisions).
- Any change to how references behave for ordinary file-backed code buffers.
- Manual/live-session end-to-end verification against the real Claude Code CLI (useful before merge, but not part of the automated test seam described above).

## Further Notes

This spec grew out of a `/grilling` session (see conversation/knowledge context) that also ruled out an alternative design worth remembering if this space is revisited later: since ghostel is real Emacs buffer text (not an opaque terminal widget), and `claude-code-ide` already exposes a genuine user-extensible MCP tool mechanism (`claude-code-ide-make-tool`), a future upstream change to wire that mechanism into the actual CLI-facing WebSocket session (rather than only the separate HTTP server it currently feeds) would reopen the lazy-resolution design as a cleaner option than the eager-capture/temp-file approach chosen here.
