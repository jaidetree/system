;;; tools/claude-code-monet/actions-mode.el -*- lexical-binding: t; -*-
;; A global minor mode whose only job is a shallow `C-c c' binding onto
;; `claude-code-command-map' (upstream's own suggested binding), so Claude
;; actions -- send region/file, clipboard mention, fix error at point, new
;; instance, etc. -- don't require going through the `SPC o c' leader path.
;; `SPC o c' is reserved for `+claude-code-monet-toggle-or-start'.

(defvar claude-code-monet-actions-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c c") claude-code-command-map)
    map)
  "Keymap for `claude-code-monet-actions-mode': `C-c c' followed by any key
from `claude-code-command-map' (e.g. `C-c c r' to send the region, `C-c c
y' to mention the clipboard, `C-c c e' to fix the error at point).")

(define-minor-mode claude-code-monet-actions-mode
  "Global minor mode giving shallow `C-c c' access to
`claude-code-command-map', so Claude actions are reachable without the
`SPC o c' leader prefix."
  :global t
  :group 'claude-code
  :keymap claude-code-monet-actions-mode-map)

(provide 'claude-code-monet-actions-mode)
