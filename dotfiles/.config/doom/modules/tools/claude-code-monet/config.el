;;; tools/claude-code-monet/config.el -*- lexical-binding: t; -*-
;; claude-code.el + monet, ghostel backend.
;; `SPC o c' toggles/creates the project's Claude window; `C-c c' (via
;; `claude-code-monet-actions-mode') is the shallow path to everything else
;; in `claude-code-command-map' (send region, clipboard mention, fix error
;; at point, ...). See actions-mode.el.

(defun +claude-code-monet-toggle-or-start ()
  "Toggle the current project's Claude window, starting a session first if
none exists yet. Delegates to `claude-code-toggle' once a buffer exists, so
window-display behavior (`claude-code-display-window-fn',
`claude-code-toggle-auto-select', etc) stays in sync with upstream --
this only decides whether a session needs starting first."
  (interactive)
  (if (claude-code--get-or-prompt-for-buffer)
      (claude-code-toggle)
    (claude-code)))

;; :config default binds `SPC o' after us, so defer this map! until after all
;; module configs have loaded — otherwise our entry gets clobbered.
(add-hook 'doom-after-modules-config-hook
          (lambda ()
            (map! :leader
                  (:prefix "o"
                   :desc "Claude Code" "c" #'+claude-code-monet-toggle-or-start))))

(use-package! claude-code
  :config
  (setq claude-code-terminal-backend 'ghostel)
  (claude-code-mode)
  (load! "clipboard-ref")
  (define-key claude-code-command-map (kbd "y")
              #'+claude-code-monet-insert-clipboard-mentioned)
  (load! "actions-mode")
  (claude-code-monet-actions-mode 1))

(use-package! monet
  :after claude-code
  :config
  (monet-mode)
  (add-hook 'claude-code-process-environment-functions
            #'monet-start-server-function))
