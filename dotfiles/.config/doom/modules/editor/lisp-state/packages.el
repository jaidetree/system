;; -*- no-byte-compile: t; -*-
;;; editor/lisp-state/packages.el

;; My fork of the Spacemacs evil-lisp-state plugin: an evil "lisp state" for
;; structural sexp editing, with Doom compatibility changes at the source
;; level (backend-aware undo/redo instead of hard-coded undo-tree, and the
;; "." toggle reachable from normal state) — see
;; https://github.com/jaidetree/evil-lisp-state.
(package! evil-lisp-state
  :recipe (:host github :repo "jaidetree/evil-lisp-state"))
