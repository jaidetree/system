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

(defun +lisp-state-setup ()
  (require 'evil-lisp-state)
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
  (evil-lisp-state-leader "SPC k")
  (setq evil-lisp-state-cursor (list "magenta" '(bar . 2)))
  (add-hook 'evil-lisp-state-entry-hook #'+lisp-state-modeline-enter)
  (add-hook 'evil-lisp-state-exit-hook #'+lisp-state-modeline-exit)
  ;; Installed once, not per entry/exit: advice isn't buffer-local like
  ;; face-remap, so toggling it per-buffer could leave another buffer's
  ;; icon stale.
  (advice-add 'doom-modeline--modal-icon :around #'+lisp-state--modal-icon-advice))

(provide 'lisp-state-setup)
