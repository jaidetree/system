;;; tools/claude-code-monet/clipboard-ref.el -*- lexical-binding: t; -*-
;; Mirrors claude-code.el's own image-paste pattern
;; (`claude-code--image-yank-media-handler': write to a temp file, then
;; `@path' into the terminal) for arbitrary clipboard text -- useful when a
;; terminal multiplexer (e.g. zellij with `copy_on_select') captures a
;; mouse-drag selection itself and copies it straight to the system
;; clipboard, so there's never an Emacs region for `claude-code-send-region'
;; to see.

(defun +claude-code-monet--clipboard-temp-file ()
  "Return a fresh temp-file path for a clipboard-reference snapshot."
  (make-temp-file "claude-clipboard-" nil ".txt"))

(defun +claude-code-monet-insert-clipboard-mentioned ()
  "Write the system clipboard's text content to a temp file and mention it
in the Claude pane as an `@path' reference, the same way
`claude-code-send-file' mentions a file. Signals a `user-error' if the
clipboard is empty."
  (interactive)
  (let ((text (ignore-errors (current-kill 0 t))))
    (if (or (null text) (string-empty-p (string-trim text)))
        (user-error "Clipboard is empty")
      (let ((path (+claude-code-monet--clipboard-temp-file)))
        (write-region text nil path nil 'silent)
        (claude-code--do-send-command (format "@%s" path))))))

(provide 'claude-code-monet-clipboard-ref)
