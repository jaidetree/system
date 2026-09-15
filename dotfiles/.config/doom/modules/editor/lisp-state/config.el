;;; editor/lisp-state/config.el -*- lexical-binding: t; -*-
;; Adds an evil "lisp state" for structural sexp editing (slurp, barf,
;; raise, convolute, splice, wrap, ...) with Spacemacs-style mnemonics
;; under "SPC k". Any command below enters lisp state; ESC returns to
;; normal state. "SPC k ." toggles the state manually from anywhere.
;; The Doom adaptations live in setup.el so the integration test can
;; exercise them in a batch session.
(load! "setup")

(use-package! evil-lisp-state
  ;; Deferred until evil and smartparens are loaded (i.e. when the first
  ;; relevant buffer opens); `+lisp-state-setup' then installs the "SPC k"
  ;; leader, the major-mode list, and the undo-fu bindings.
  :after evil smartparens
  :config
  (+lisp-state-setup))
