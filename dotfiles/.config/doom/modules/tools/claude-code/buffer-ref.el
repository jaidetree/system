;;; tools/claude-code/buffer-ref.el -*- lexical-binding: t; -*-
;; Separate from config.el so test/claude-code-buffer-ref-test.el can load it
;; directly, without pulling in `use-package!'/`map!' or a live claude-code-ide
;; session.
;;
;; Lets `claude-code-ide-insert-at-mentioned' (SPC o c i) also work from
;; buffers with no backing file (ghostel, eshell, shell-mode, magit,
;; *Messages*, ...): the active region is captured into a labeled temp file
;; and handed to claude-code-ide's own, unmodified send path. See
;; .system-vault/Projects/doom/ghostel-buffer-references/Spec.md.

(defvar +claude-code-ide--temp-file-dir nil
  "Session-scoped temp directory for non-file-buffer references.
Created lazily on first use; one per Emacs session.")

(defun +claude-code-ide--temp-file-dir ()
  "Return this session's temp dir for buffer references, creating it once."
  (or (and +claude-code-ide--temp-file-dir
           (file-directory-p +claude-code-ide--temp-file-dir)
           +claude-code-ide--temp-file-dir)
      (setq +claude-code-ide--temp-file-dir
            (make-temp-file "claude-code-ide-refs-" t))))

(defun +claude-code-ide--temp-file-name (buffer-name)
  "Return a fresh temp-file path labeled from BUFFER-NAME and a timestamp."
  (expand-file-name
   (format "%s-%s.txt"
           (replace-regexp-in-string "[^A-Za-z0-9_-]+" "_" buffer-name)
           (format-time-string "%Y%m%dT%H%M%S%3N"))
   (+claude-code-ide--temp-file-dir)))

(defun +claude-code-ide--ghostel-buffer-p ()
  "Non-nil when the current buffer is derived from `ghostel-mode'.
Referenced dynamically (via `derived-mode-p', which only inspects
`major-mode' and its `derived-mode-parent' chain) so this works whether or
not the real ghostel package is loaded -- a test can simulate a ghostel
buffer just by setting `major-mode' locally."
  (derived-mode-p 'ghostel-mode))

(defun +claude-code-ide--ghostel-selection-capable-p ()
  "Non-nil when the current ghostel buffer's input mode already supports an
Evil/Emacs selection (ghostel's `copy' or `emacs' input modes, out of its
five: semi-char, char, line, emacs, copy). Reads `ghostel--input-mode' via
`bound-and-true-p' so this is safe to call even when ghostel isn't loaded."
  (memq (bound-and-true-p ghostel--input-mode) '(copy emacs)))

(defun +claude-code-ide--ghostel-ensure-copy-mode ()
  "Switch the current buffer into ghostel copy-mode if needed.

No-op unless the buffer is a ghostel buffer (`+claude-code-ide--ghostel-buffer-p')
not already in a selection-capable input mode
(`+claude-code-ide--ghostel-selection-capable-p'). Calls `ghostel-copy-mode'
via `fboundp'/`funcall' (rather than a direct call) so a test can stub it out
without the real ghostel package loaded -- and so a buffer already in
copy-mode is never toggled back out of it, since `ghostel-copy-mode' itself
toggles."
  (when (and (+claude-code-ide--ghostel-buffer-p)
             (not (+claude-code-ide--ghostel-selection-capable-p))
             (fboundp 'ghostel-copy-mode))
    (funcall #'ghostel-copy-mode)))

(defun +claude-code-ide--relay-text-as-mentioned (text label send-fn)
  "Write TEXT to a session temp file labeled from LABEL, visit it with its
whole contents marked as the active region, preserve the calling buffer's
`default-directory' (so session/project resolution behaves as if invoked
from there), then invoke SEND-FN with that buffer current -- so a send
function like `claude-code-ide-mcp-send-at-mentioned', called unmodified,
resolves its own `(buffer-file-name)' and region/line lookups against the
temp file."
  (let ((dir default-directory)
        (temp-file (+claude-code-ide--temp-file-name label)))
    (write-region text nil temp-file nil 'silent)
    (with-current-buffer (find-file-noselect temp-file)
      (setq-local default-directory dir)
      (goto-char (point-min))
      (push-mark (point-max) t t)
      (funcall send-fn))))

(defun +claude-code-ide-at-mentioned-for-buffer (send-fn)
  "Dispatch SEND-FN so it also works from buffers with no backing file.

When the current buffer has no `buffer-file-name', a ghostel-specific
pre-step runs first: `+claude-code-ide--ghostel-ensure-copy-mode' switches a
ghostel buffer that isn't already in copy-mode/emacs-mode into copy-mode, so
an Evil selection is actually honored (ghostel's default semi-char mode
forwards keystrokes straight to the PTY). This step is a no-op for
non-ghostel buffers (eshell, shell-mode, ...), which have no such input-mode
concept.

Then, if there's an active region, its text is captured immediately with
`buffer-substring-no-properties' (a ghostel buffer's scrollback can evict
lines later, so this can't be deferred) and relayed via
`+claude-code-ide--relay-text-as-mentioned'.

A file-backed buffer falls through to SEND-FN unchanged, region or not (and
never runs the ghostel pre-step). A non-file buffer with no active region is
a no-op: no temp file is created and SEND-FN is not called."
  (cond
   ((buffer-file-name) (funcall send-fn))
   (t
    (+claude-code-ide--ghostel-ensure-copy-mode)
    (when (use-region-p)
      (+claude-code-ide--relay-text-as-mentioned
       (buffer-substring-no-properties (region-beginning) (region-end))
       (buffer-name)
       send-fn)))))

(defun +claude-code-ide-insert-clipboard-mentioned (&optional send-fn)
  "Reference the system clipboard's content in the Claude Code chat.

For terminal multiplexers (e.g. zellij with `copy_on_select') that capture
mouse-drag selection themselves and copy it straight to the system
clipboard, bypassing Emacs entirely -- there's never an Emacs region for
`+claude-code-ide-at-mentioned-for-buffer' to see, no matter what ghostel
input mode the buffer is in. Meant to be invoked from the ghostel buffer
you selected in (not a scrollback-editor buffer opened via `emacsclient' in
some unrelated temp directory): its `default-directory' is what
`+claude-code-ide--relay-text-as-mentioned' preserves for correct
project/session resolution.

SEND-FN defaults to `claude-code-ide-insert-at-mentioned' (the real,
unmodified command); tests can pass a stub instead. Signals a `user-error'
if the clipboard is empty, without creating a temp file or calling SEND-FN."
  (interactive)
  (let ((text (ignore-errors (current-kill 0 t))))
    (if (or (null text) (string-empty-p (string-trim text)))
        (user-error "Clipboard is empty")
      (+claude-code-ide--relay-text-as-mentioned
       text (buffer-name) (or send-fn #'claude-code-ide-insert-at-mentioned)))))

(defun +claude-code-ide-insert-at-mentioned-a (orig-fn &rest args)
  "Around-advice: route `claude-code-ide-insert-at-mentioned' through
`+claude-code-ide-at-mentioned-for-buffer' so SPC o c i also works from
non-file buffers. See its docstring."
  (+claude-code-ide-at-mentioned-for-buffer (lambda () (apply orig-fn args))))

(defconst +claude-code-ide-temp-file-max-age (* 4 60 60)
  "Max age in seconds a reference temp file may reach before the periodic
sweep deletes it. Comfortably longer than the capture-to-send window (the
file is visited and sent essentially immediately after being written), so
this only ever catches files whose send never happened (e.g. the command
was aborted) -- never one that's actively in flight.")

(defconst +claude-code-ide-temp-file-sweep-interval (* 30 60)
  "Seconds between periodic sweeps of the session's temp-file directory.")

(defvar +claude-code-ide--temp-file-sweep-timer nil
  "The `run-with-timer' handle for the periodic sweep, or nil if unset.")

(defun +claude-code-ide--temp-file-dir-cleanup ()
  "Recursively delete the session's temp-file directory, if it was ever
created. Safe to call when `+claude-code-ide--temp-file-dir' is nil (no
reference has ever been sent this session)."
  (when (and +claude-code-ide--temp-file-dir
             (file-directory-p +claude-code-ide--temp-file-dir))
    (delete-directory +claude-code-ide--temp-file-dir t)))

(defun +claude-code-ide--temp-file-sweep ()
  "Delete files in the session's temp-file directory older than
`+claude-code-ide-temp-file-max-age'. A no-op if the directory hasn't been
created yet. Never touches a file younger than the threshold, so a
reference that was just captured and is mid-send is never at risk."
  (when (and +claude-code-ide--temp-file-dir
             (file-directory-p +claude-code-ide--temp-file-dir))
    (let ((cutoff (- (float-time) +claude-code-ide-temp-file-max-age)))
      (dolist (file (directory-files +claude-code-ide--temp-file-dir t
                                      directory-files-no-dot-files-regexp))
        (when (and (file-regular-p file)
                   (< (float-time (file-attribute-modification-time
                                    (file-attributes file)))
                      cutoff))
          (delete-file file))))))

(defun +claude-code-ide--transient-add-clipboard-suffix ()
  "Add \"y\" (Insert clipboard as reference) next to \"i\" in
`claude-code-ide-menu', via the transient package's own extension API --
never edit the vendored `claude-code-ide-transient.el' source."
  (transient-append-suffix 'claude-code-ide-menu "i"
    '("y" "Insert clipboard as reference" +claude-code-ide-insert-clipboard-mentioned)))

(defun +claude-code-ide-buffer-ref-setup ()
  "Install the SPC o c i dispatch advice, the clipboard-reference transient
suffix, and the temp-file cleanup lifecycle (exit hook + periodic sweep).
Call after claude-code-ide loads."
  (advice-add #'claude-code-ide-insert-at-mentioned :around
              #'+claude-code-ide-insert-at-mentioned-a)
  (with-eval-after-load 'claude-code-ide-transient
    (+claude-code-ide--transient-add-clipboard-suffix))
  (add-hook 'kill-emacs-hook #'+claude-code-ide--temp-file-dir-cleanup)
  (unless +claude-code-ide--temp-file-sweep-timer
    (setq +claude-code-ide--temp-file-sweep-timer
          (run-with-timer +claude-code-ide-temp-file-sweep-interval
                           +claude-code-ide-temp-file-sweep-interval
                           #'+claude-code-ide--temp-file-sweep))))

(provide 'claude-code-buffer-ref)
