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

(defun +claude-code-ide-at-mentioned-for-buffer (send-fn)
  "Dispatch SEND-FN so it also works from buffers with no backing file.

When the current buffer has no `buffer-file-name' and an active region,
the region's text is captured immediately with
`buffer-substring-no-properties' (a ghostel buffer's scrollback can evict
lines later, so this can't be deferred), written to a session-scoped temp
file named from the buffer name plus a timestamp, and SEND-FN is invoked
with that temp file visited and its whole contents marked as the active
region -- so a send function like `claude-code-ide-mcp-send-at-mentioned',
called unmodified, resolves its own `(buffer-file-name)' and region/line
lookups against the temp file.

A file-backed buffer falls through to SEND-FN unchanged, region or not.
A non-file buffer with no active region is a no-op: no temp file is
created and SEND-FN is not called."
  (cond
   ((buffer-file-name) (funcall send-fn))
   ((use-region-p)
    (let ((text (buffer-substring-no-properties (region-beginning) (region-end)))
          (dir default-directory)
          (temp-file (+claude-code-ide--temp-file-name (buffer-name))))
      (write-region text nil temp-file nil 'silent)
      (with-current-buffer (find-file-noselect temp-file)
        ;; Keep the source buffer's working directory so session resolution
        ;; (project-root lookup) behaves as if invoked from there.
        (setq-local default-directory dir)
        (goto-char (point-min))
        (push-mark (point-max) t t)
        (funcall send-fn))))
   (t nil)))

(defun +claude-code-ide-insert-at-mentioned-a (orig-fn &rest args)
  "Around-advice: route `claude-code-ide-insert-at-mentioned' through
`+claude-code-ide-at-mentioned-for-buffer' so SPC o c i also works from
non-file buffers. See its docstring."
  (+claude-code-ide-at-mentioned-for-buffer (lambda () (apply orig-fn args))))

(defun +claude-code-ide-buffer-ref-setup ()
  "Install the SPC o c i dispatch advice. Call after claude-code-ide loads."
  (advice-add #'claude-code-ide-insert-at-mentioned :around
              #'+claude-code-ide-insert-at-mentioned-a))

(provide 'claude-code-buffer-ref)
