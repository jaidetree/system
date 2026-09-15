;;; editor/lisp-state/test/lisp-state-test.el -*- lexical-binding: t; -*-
;; Integration test for the evil-lisp-state setup in ../setup.el (wired
;; into ../config.el).
;;
;; Run it (no Doom CLI needed; it bootstraps its own load-path from
;; straight's build tree, because batch sessions skip user config):
;;
;;   emacs -Q --batch -l ~/.config/doom/modules/editor/lisp-state/test/lisp-state-test.el
;;
;; Prints "lisp-state OK — N checks passed" and exits 0 when every
;; binding is live; exits non-zero with a "FAILED: ..." message naming
;; the broken assertion otherwise.

;; --- bootstrap: straight's built packages ---
(let ((build-dir (expand-file-name
                  ".local/straight/build-31.0.91/"
                  (or (getenv "EMACSDIR") "~/.config/emacs/"))))
  (dolist (pkg '("evil-lisp-state" "bind-map" "evil" "smartparens"
                 "dash" "undo-fu" "goto-chg"))
    (add-to-list 'load-path (concat build-dir pkg))))

;; --- the real integration: same code config.el runs ---
(require 'evil)
(require 'smartparens)
;; Doom's :editor undo module always has undo-fu loaded; the fork's
;; lisp-state-undo/redo dispatch to it at runtime. Load it so the batch
;; environment matches what the bindings will actually run against.
(require 'undo-fu)
;; Stub the doom-modeline face `+lisp-state-modeline-enter' remaps, so
;; the modeline-integration checks below don't need to pull in the whole
;; doom-modeline package (icons, nerd-fonts, etc.) just to exist.
(defface doom-modeline-evil-user-state '((t)) "Stub for batch tests.")
(load (expand-file-name "../setup.el" (file-name-directory load-file-name)))
(+lisp-state-setup)

;; --- assertions ---
(let ((checks
       ;; (description . result)
       `(("evil-lisp-state feature loaded" . ,(featurep 'evil-lisp-state))
         ("slurp bound under SPC k (major-mode map)"
          . ,(eq (lookup-key evil-lisp-state-major-mode-map "s")
                 'evil-lisp-state-sp-forward-slurp-sexp))
         ("SPC k u is the fork's backend-aware undo (evil-lisp-state-undo)"
          . ,(eq (lookup-key evil-lisp-state-major-mode-map "u")
                 'evil-lisp-state-undo))
         ("SPC k C-r is the fork's backend-aware redo"
          . ,(eq (lookup-key evil-lisp-state-major-mode-map "\C-r")
                 'evil-lisp-state-redo))
         ("SPC k . toggles lisp state from normal state (fork change)"
          . ,(eq (lookup-key evil-lisp-state-major-mode-map ".")
                 'lisp-state-toggle-lisp-state))
         ("u inside lisp state dispatches to undo-fu"
          . ,(and (eq (lookup-key evil-lisp-state-map "u")
                      'lisp-state-undo)
                  (fboundp 'lisp-state-undo)
                  (fboundp 'undo-fu-only-undo)))
         ("C-r inside lisp state dispatches to undo-fu redo"
          . ,(and (eq (lookup-key evil-lisp-state-map "\C-r")
                      'lisp-state-redo)
                  (fboundp 'undo-fu-only-redo)))
         ("clojure-mode covered by the SPC k map"
          . ,(memq 'clojure-mode evil-lisp-state-major-modes))
         ("janet-mode covered by the SPC k map"
          . ,(memq 'janet-mode evil-lisp-state-major-modes))
         ("bind-map registered the SPC k prefix for evil normal state"
          . ,(let* ((root-sym (get 'evil-lisp-state-major-mode-map :root-map))
                    (root (and (boundp root-sym) (symbol-value root-sym)))
                    (aux (and root (evil-get-auxiliary-keymap root 'normal))))
               (and aux
                    (lookup-key aux (kbd "SPC k"))
                    ;; the prefix command's function slot is the map
                    (fboundp (lookup-key aux (kbd "SPC k"))))))
         ("lisp state has its own cursor color, not the shared default"
          . ,(equal evil-lisp-state-cursor (list "magenta" '(bar . 2))))
         ("entering lisp state remaps the modeline evil-user-state face"
          . ,(with-temp-buffer
               (evil-local-mode 1)
               (evil-lisp-state)
               (prog1 (and +lisp-state--modeline-cookie
                           (member '+lisp-state-modeline-face
                                   (alist-get 'doom-modeline-evil-user-state
                                              face-remapping-alist)))
                 (evil-normal-state))))
         ("leaving lisp state removes the modeline face remap"
          . ,(with-temp-buffer
               (evil-local-mode 1)
               (evil-lisp-state)
               (evil-normal-state)
               (and (null +lisp-state--modeline-cookie)
                    (null (alist-get 'doom-modeline-evil-user-state
                                     face-remapping-alist)))))))
       (failed nil))
  (dolist (c checks)
    (unless (cdr c) (push (car c) failed)))
  (if failed
      (error "FAILED: %s" (string-join (nreverse failed) "; "))
    (message "lisp-state OK — %d checks passed" (length checks))))
