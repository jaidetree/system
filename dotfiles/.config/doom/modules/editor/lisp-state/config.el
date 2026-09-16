;;; editor/lisp-state/config.el -*- lexical-binding: t; -*-
;; Adds an evil "lisp state" for structural sexp editing under "SPC k".
(load! "setup")

(use-package! evil-lisp-state
  :after evil smartparens
  :config
  (+lisp-state-setup))
