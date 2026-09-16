;;; editor/lisp-state/test/lisp-state-test.el -*- lexical-binding: t; -*-
;; Run: emacs -Q --batch -l ~/.config/doom/modules/editor/lisp-state/test/lisp-state-test.el

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
(require 'undo-fu)
;; Stubs so the modeline checks don't need to pull in doom-modeline itself.
(defface doom-modeline-evil-user-state '((t)) "Stub for batch tests.")
(defun doom-modeline--modal-icon (text face help-echo &optional icon unicode)
  (list text face help-echo icon unicode))
;; A non-default value, so the prefix check below actually exercises the
;; dynamic `doom-leader-key' reference rather than a value it'd pass under
;; either way.
(defvar doom-leader-key ",")
(load (expand-file-name "../setup.el" (file-name-directory load-file-name)))
(+lisp-state-setup)

;; --- assertions ---
(let ((checks
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
         ("fennel-mode covered by the SPC k map"
          . ,(memq 'fennel-mode evil-lisp-state-major-modes))
         ("bind-map registered the leader-relative prefix for evil normal state"
          . ,(let* ((root-sym (get 'evil-lisp-state-major-mode-map :root-map))
                    (root (and (boundp root-sym) (symbol-value root-sym)))
                    (aux (and root (evil-get-auxiliary-keymap root 'normal))))
               (and aux
                    (lookup-key aux (kbd (concat doom-leader-key " k")))
                    ;; the prefix command's function slot is the map
                    (fboundp (lookup-key aux (kbd (concat doom-leader-key " k")))))))
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
                                     face-remapping-alist)))))
         ("modal-icon advice swaps in the lisp glyph when evil-state is lisp"
          . ,(let ((evil-state 'lisp))
               (equal (doom-modeline--modal-icon
                       " <L> " 'doom-modeline-evil-user-state "lisp"
                       "nf-md-alpha_u_circle" "🅤")
                      (list " <L> " 'doom-modeline-evil-user-state "lisp"
                            "nf-md-alpha_l_circle" "🅛"))))
         ("modal-icon advice leaves other evil states on the fallback glyph"
          . ,(let ((evil-state 'normal))
               (equal (doom-modeline--modal-icon
                       " <N> " 'doom-modeline-evil-user-state "normal"
                       "nf-md-alpha_u_circle" "🅤")
                      (list " <N> " 'doom-modeline-evil-user-state "normal"
                            "nf-md-alpha_u_circle" "🅤"))))
         ("modal-icon advice leaves non-evil modal segments untouched"
          . ,(let ((evil-state 'lisp))
               (equal (doom-modeline--modal-icon
                       "<W>" 'doom-modeline-overwrite "Overwrite mode"
                       "nf-md-marker" "✍")
                      (list "<W>" 'doom-modeline-overwrite "Overwrite mode"
                            "nf-md-marker" "✍"))))))
       (failed nil))
  (dolist (c checks)
    (unless (cdr c) (push (car c) failed)))
  (if failed
      (error "FAILED: %s" (string-join (nreverse failed) "; "))
    (message "lisp-state OK — %d checks passed" (length checks))))
