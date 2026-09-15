;;; editor/lisp-state/setup.el -*- lexical-binding: t; -*-
;;; Commentary:
;; Doom adaptations for evil-lisp-state (fork: jaidetree/evil-lisp-state,
;; vendored at vendor/evil-lisp-state/). Called from the `use-package!
;; evil-lisp-state' :config in config.el, so it runs once evil and
;; smartparens are loaded in an interactive session. Kept in its own file
;; (rather than inline in config.el) so that test/lisp-state-test.el can
;; load and exercise this exact code in a batch session, where Doom skips
;; user config entirely.
;;; Code:

(defface +lisp-state-modeline-face
  '((t (:inherit (doom-modeline font-lock-constant-face))))
  "Face for the lisp state tag in the doom-modeline evil indicator.
Mirrors how doom-modeline styles the built-in states (see
`doom-modeline-evil-normal-state', `doom-modeline-evil-insert-state', etc.
in doom-modeline-core.el) so lisp state reads as a first-class evil state
instead of falling into the generic \"unknown state\" styling.")

(defvar-local +lisp-state--modeline-cookie nil
  "face-remap cookie installed while lisp state is active, so it can be
removed again on exit. Buffer-local because `face-remap-add-relative' is.")

(defun +lisp-state-modeline-enter ()
  "Swap in `+lisp-state-modeline-face' for the modeline evil indicator.

`doom-modeline--evil' (doom-modeline-segments.el) hard-codes lisp state — an
evil state it doesn't recognize — to the catch-all
`doom-modeline-evil-user-state' face. That function is a `defsubst', inlined
into the byte-compiled `doom-modeline-segment--modals' at package build
time, so neither redefining nor advising it changes what the modeline
already shows. Remapping the fallback face itself, only while lisp state is
current, works around that without touching doom-modeline's code."
  (setq +lisp-state--modeline-cookie
        (face-remap-add-relative 'doom-modeline-evil-user-state
                                  '+lisp-state-modeline-face)))

(defun +lisp-state-modeline-exit ()
  "Undo `+lisp-state-modeline-enter', restoring the shared fallback face."
  (when +lisp-state--modeline-cookie
    (face-remap-remove-relative +lisp-state--modeline-cookie)
    (setq +lisp-state--modeline-cookie nil)))

(defun +lisp-state-setup ()
  "Wire evil-lisp-state into Doom.

Sets the major modes the \"SPC k\" prefix is active in, replaces the
upstream undo-tree bindings with Doom's undo-fu, and installs the
\"SPC k\" leader. Any \"SPC k\" command enters lisp state (per
`evil-lisp-state-enter-lisp-state-on-command'); ESC returns to normal
state; \"SPC k .\" toggles the state explicitly."
  (require 'evil-lisp-state)
  ;; The SPC k bindings are only active in these major modes (outside them
  ;; only "SPC k ." works, to toggle into the state). bind-map reads this
  ;; variable when `evil-lisp-state-leader' runs below.
  (setq evil-lisp-state-major-modes
        '(emacs-lisp-mode
          lisp-interaction-mode
          lisp-mode
          clojure-mode
          clojurec-mode
          clojurescript-mode
          janet-mode
          racket-mode
          scheme-mode))
  ;; The undo/redo backend handling ("u"/"C-r" dispatch to undo-fu,
  ;; undo-tree, or plain undo) and the "." toggle under the prefix live in
  ;; the fork's source (vendor/evil-lisp-state/evil-lisp-state.el) —
  ;; nothing to adapt on the config side for those.
  ;; Spacemacs-compatible prefix. Examples: SPC k s (slurp), SPC k b
  ;; (barf), SPC k r (raise), SPC k w (wrap), SPC k t (transpose), SPC k
  ;; j/k (next/previous paren), SPC k ds/dw/dx (delete symbol/word/sexp).
  (evil-lisp-state-leader "SPC k")
  ;; Give lisp state its own cursor color (matching bar shape from the
  ;; upstream `evil-define-state' call) instead of inheriting whatever
  ;; color was last set, so it reads as distinctly as normal/insert do.
  (setq evil-lisp-state-cursor (list "magenta" '(bar . 2)))
  ;; Give lisp state its own modeline color too — see
  ;; `+lisp-state-modeline-enter' for why this can't be done by
  ;; configuring doom-modeline directly.
  (add-hook 'evil-lisp-state-entry-hook #'+lisp-state-modeline-enter)
  (add-hook 'evil-lisp-state-exit-hook #'+lisp-state-modeline-exit))

(provide 'lisp-state-setup)
