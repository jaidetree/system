;;; tools/claude-code/config.el -*- lexical-binding: t; -*-
;; MCP-based Claude Code integration. Transient menu on SPC o c.

;; :config default binds `SPC o` after us, so defer this map! until after all
;; module configs have loaded — otherwise our entry gets clobbered.
(add-hook 'doom-after-modules-config-hook
          (lambda ()
            (map! :leader
                  (:prefix "o"
                   :desc "Claude Code" "c" #'claude-code-ide-menu))))

(use-package! claude-code-ide
  :defer t
  :commands (claude-code-ide-menu)
  :config
  (setq claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-emacs-tools-setup))
