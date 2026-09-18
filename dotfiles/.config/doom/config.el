;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'catppuccin)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq ghostel-shell "/etc/profiles/per-user/j/bin/fish")

;; TEMPORARY: https://github.com/doomemacs/modules/issues/81 — +ghostel/toggle's reset
;; branch references the wrong let-bound var. Remove once fixed upstream.
;;
;; +ghostel--buffer-name is copied in too: upstream defines it without an
;; ;;;###autoload cookie, so Doom's compiled autoloads never include it and
;; it stays void unless term/ghostel/autoload.el happens to be loaded in full.
(defun +ghostel--buffer-name (&optional prefix suffix project?)
  (format "*%sghostel%s%s<%s>*"
          (or prefix "")
          (or suffix "")
          (if project?
              (concat
               ":" (or (doom-project-name)
                       (file-name-nondirectory
                        (directory-file-name default-directory))))
            "")
          (if (bound-and-true-p persp-mode)
              (safe-persp-name (get-current-persp))
            "main")))

(defun +ghostel/toggle (&optional arg)
  "Toggle a persistent terminal popup window at project root.

If prefix ARG is non-nil, recreate the ghostel buffer in the current project's
root.

Returns the ghostel buffer."
  (interactive "P")
  (dlet ((default-directory (or (doom-project-root) default-directory)))
    (dlet ((ghostel-buffer-name (+ghostel--buffer-name "doom:" "-popup" t))
           ghostel-buffer-name-function
           confirm-kill-processes
           current-prefix-arg)
      (when arg
        (let ((buffer (get-buffer ghostel-buffer-name))
              (window (get-buffer-window ghostel-buffer-name)))
          (when (buffer-live-p buffer)
            (kill-buffer buffer))
          (when (window-live-p window)
            (delete-window window))))
      (if-let* ((win (get-buffer-window ghostel-buffer-name)))
          (delete-window win)
        (with-current-buffer (ghostel)
          (setq-local ghostel-buffer-name-function nil)
          (set-window-dedicated-p (get-buffer-window) t)
          (current-buffer))))))

