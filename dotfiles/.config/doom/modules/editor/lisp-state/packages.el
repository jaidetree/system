;; -*- no-byte-compile: t; -*-
;;; editor/lisp-state/packages.el

;; My fork of the Spacemacs evil-lisp-state plugin: an evil "lisp state" for
;; structural sexp editing. Vendored at vendor/evil-lisp-state/ (with Doom
;; compatibility changes at the source level: backend-aware undo/redo
;; instead of hard-coded undo-tree, and the "." toggle reachable from
;; normal state); straight builds from that local tree.
(package! evil-lisp-state
  :recipe (:local-repo "vendor/evil-lisp-state"))
