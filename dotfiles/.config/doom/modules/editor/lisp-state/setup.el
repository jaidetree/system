;;; editor/lisp-state/setup.el -*- lexical-binding: t; -*-
;; Separate from config.el so test/lisp-state-test.el can load it directly.

(defface +lisp-state-modeline-face
  '((t (:inherit (doom-modeline font-lock-constant-face))))
  "Face for lisp state in the doom-modeline evil indicator.")

(defvar-local +lisp-state--modeline-cookie nil)

(defun +lisp-state-modeline-enter ()
  "Remap doom-modeline's evil-user-state face to `+lisp-state-modeline-face'.
`doom-modeline--evil' is a defsubst inlined at package build time, so it
can't be redefined or advised — remapping its fallback face is the
workaround."
  (setq +lisp-state--modeline-cookie
        (face-remap-add-relative 'doom-modeline-evil-user-state
                                  '+lisp-state-modeline-face)))

(defun +lisp-state-modeline-exit ()
  (when +lisp-state--modeline-cookie
    (face-remap-remove-relative +lisp-state--modeline-cookie)
    (setq +lisp-state--modeline-cookie nil)))

(defun +lisp-state--modal-icon-advice (fn text face help-echo &optional icon unicode)
  "Swap the generic evil \"user state\" icon for lisp state's own.
Unlike `doom-modeline--evil', `doom-modeline--modal-icon' is a plain defun
and so can be advised. Guarded on FACE and `evil-state' so only lisp
state is affected."
  (if (and (eq face 'doom-modeline-evil-user-state)
           (eq (bound-and-true-p evil-state) 'lisp))
      (funcall fn text face help-echo "nf-md-alpha_l_circle" "🅛")
    (funcall fn text face help-echo icon unicode)))

(defun +lisp-state-undo-backend (&optional arg)
  "Undo via whichever backend is loaded: undo-fu, undo-tree, or plain undo.
Upstream evil-lisp-state hard-codes undo-tree, which Doom doesn't ship."
  (interactive "P")
  (cond ((fboundp 'undo-fu-only-undo) (undo-fu-only-undo arg))
        ((fboundp 'undo-tree-undo) (undo-tree-undo arg))
        (t (undo arg))))

(defun +lisp-state-redo-backend (&optional arg)
  "Redo counterpart to `+lisp-state-undo-backend'."
  (interactive "P")
  (cond ((fboundp 'undo-fu-only-redo) (undo-fu-only-redo arg))
        ((fboundp 'undo-tree-redo) (undo-tree-redo arg))
        ((fboundp 'undo-redo) (undo-redo arg))
        (t (message "lisp-state: no redo backend available"))))

(defun +lisp-state-undo ()
  "SPC k u: enter lisp state (mirroring evil-lisp-state-enter-command's
wrapping of other SPC k commands), then undo via `+lisp-state-undo-backend'."
  (interactive)
  (when evil-lisp-state-enter-lisp-state-on-command
    (evil-lisp-state))
  (call-interactively #'+lisp-state-undo-backend))

(defun +lisp-state-redo ()
  "SPC k C-r counterpart to `+lisp-state-undo'."
  (interactive)
  (when evil-lisp-state-enter-lisp-state-on-command
    (evil-lisp-state))
  (call-interactively #'+lisp-state-redo-backend))

(defun +lisp-state-setup ()
  (require 'evil-lisp-state)
  ;; Rebind after load: upstream's evil-lisp-state-commands table hard-codes
  ;; undo-tree-undo/-redo on "u"/"C-r" (both directly in evil-lisp-state-map
  ;; and, via that table, under "SPC k" in evil-lisp-state-major-mode-map).
  (define-key evil-lisp-state-map "u" #'+lisp-state-undo-backend)
  (define-key evil-lisp-state-map "\C-r" #'+lisp-state-redo-backend)
  (define-key evil-lisp-state-major-mode-map "u" #'+lisp-state-undo)
  (define-key evil-lisp-state-major-mode-map "\C-r" #'+lisp-state-redo)
  ;; Upstream only binds the lisp-state toggle inside evil-lisp-state-map,
  ;; so with evil-lisp-state-global nil there's no way into the state from
  ;; normal state without a SPC k command first. Must NOT route through
  ;; evil-lisp-state-enter-command, which would enter the state first and
  ;; make the toggle a no-op.
  (unless evil-lisp-state-global
    (define-key evil-lisp-state-major-mode-map "." #'lisp-state-toggle-lisp-state))
  (setq evil-lisp-state-major-modes
        '(emacs-lisp-mode
          lisp-interaction-mode
          lisp-mode
          clojure-mode
          clojurec-mode
          clojurescript-mode
          janet-mode
          racket-mode
          scheme-mode
          fennel-mode))
  (evil-lisp-state-leader (concat doom-leader-key " k"))
  (setq evil-lisp-state-cursor (list "magenta" '(bar . 2)))
  (add-hook 'evil-lisp-state-entry-hook #'+lisp-state-modeline-enter)
  (add-hook 'evil-lisp-state-exit-hook #'+lisp-state-modeline-exit)
  ;; Installed once, not per entry/exit: advice isn't buffer-local like
  ;; face-remap, so toggling it per-buffer could leave another buffer's
  ;; icon stale.
  (advice-add 'doom-modeline--modal-icon :around #'+lisp-state--modal-icon-advice))

(provide 'lisp-state-setup)
