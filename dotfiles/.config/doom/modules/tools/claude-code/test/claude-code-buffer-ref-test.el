;;; tools/claude-code/test/claude-code-buffer-ref-test.el -*- lexical-binding: t; -*-
;; Run: emacs -Q --batch -l ~/.config/doom/modules/tools/claude-code/test/claude-code-buffer-ref-test.el

;; --- the real code under test: no external deps, no live MCP session ---
(load (expand-file-name "../buffer-ref.el" (file-name-directory load-file-name)))

;; Batch mode starts with `transient-mark-mode' off, so `use-region-p' (which
;; the code under test relies on) would never see an active region.
(transient-mark-mode 1)

;; --- stub: ghostel's buffer-local input-mode var and its copy-mode toggle
;;     command, so ghostel-specific dispatch is testable without the real
;;     ghostel package loaded. Real `ghostel-copy-mode' toggles (entering
;;     copy-mode again from copy-mode exits it); this stub mirrors just
;;     enough of that -- flip to `copy' and count calls -- to prove the
;;     dispatch code never calls it when already selection-capable. ---
(defvar ghostel--input-mode nil
  "Stub of ghostel's buffer-local input-mode var: one of semi-char, char,
line, emacs, copy.")
(make-variable-buffer-local 'ghostel--input-mode)

(defvar +cc-test--ghostel-copy-mode-calls 0
  "Count of stub `ghostel-copy-mode' invocations, reset per scenario.")

(defun ghostel-copy-mode ()
  "Stub of ghostel's copy-mode toggle command."
  (setq +cc-test--ghostel-copy-mode-calls (1+ +cc-test--ghostel-copy-mode-calls))
  (setq-local ghostel--input-mode 'copy))

;; --- stub: records what would-be "send" invocations saw, instead of
;;     hitting a real claude-code-ide MCP session ---
(defvar +cc-test--send-log nil "List of plists, one per stub-send call.")

(defun +cc-test--stub-send ()
  "Stand-in for `claude-code-ide-mcp-send-at-mentioned', called with the
buffer under test current. Records the effective file/region instead of
sending anything."
  (push (list :file (buffer-file-name)
              :region-beg (and (use-region-p) (region-beginning))
              :region-end (and (use-region-p) (region-end))
              :content (buffer-substring-no-properties (point-min) (point-max)))
        +cc-test--send-log))

(defun +cc-test--dispatch ()
  (setq +cc-test--send-log nil)
  (+claude-code-ide-at-mentioned-for-buffer #'+cc-test--stub-send)
  (car +cc-test--send-log))

(defun +cc-test--temp-dir-file-count ()
  (if (and +claude-code-ide--temp-file-dir
           (file-directory-p +claude-code-ide--temp-file-dir))
      (length (directory-files +claude-code-ide--temp-file-dir nil
                                directory-files-no-dot-files-regexp))
    0))

;; --- scenario 1: file-backed buffer with a region ---
;; Run before any non-file scenario so "no temp dir created yet" is a real
;; assertion, not an accident of ordering.
(let* ((real-file (make-temp-file "claude-code-buffer-ref-test-file-"))
       (real-buffer nil)
       (call nil))
  (with-temp-buffer
    (insert "line one\nline two\nline three\n")
    (write-region (point-min) (point-max) real-file nil 'silent))
  (setq real-buffer (find-file-noselect real-file))
  (with-current-buffer real-buffer
    (goto-char (point-min))
    (push-mark (point-max) t t)
    (setq call (+cc-test--dispatch)))
  (defvar +cc-test--file-backed-call call)
  (defvar +cc-test--file-backed-path (file-truename real-file))
  (defvar +cc-test--dir-untouched-after-file-backed
    (null +claude-code-ide--temp-file-dir))
  (kill-buffer real-buffer)
  (delete-file real-file))

;; --- scenario 2: simulated non-file buffer with an active region ---
(let* ((buf (generate-new-buffer "*ghostel: npm run build*"))
       (call nil)
       (expected-text nil))
  (with-current-buffer buf
    (insert "0123456789ABCDEF")
    ;; A sub-selection, not the whole buffer, to prove exact capture.
    (setq expected-text (buffer-substring-no-properties 3 10))
    (goto-char 3)
    (push-mark 10 t t)
    (setq call (+cc-test--dispatch)))
  (defvar +cc-test--nonfile-call call)
  (defvar +cc-test--nonfile-expected-text expected-text)
  (defvar +cc-test--nonfile-temp-file (plist-get call :file))
  (kill-buffer buf))

;; --- scenario 3: non-file buffer, no active region ---
(let* ((buf (generate-new-buffer "*eshell*"))
       (before (+cc-test--temp-dir-file-count))
       (call nil)
       (after nil))
  (with-current-buffer buf
    (insert "some eshell output, nothing selected")
    (deactivate-mark)
    (setq call (+cc-test--dispatch)))
  (setq after (+cc-test--temp-dir-file-count))
  (defvar +cc-test--no-region-call call)
  (defvar +cc-test--no-region-file-count-unchanged (= before after))
  (kill-buffer buf))

;; --- scenario 4: simulated ghostel buffer, not in copy/emacs mode ---
(let* ((buf (generate-new-buffer "*ghostel: build*"))
       (call nil)
       (calls-before 0))
  (with-current-buffer buf
    (setq-local major-mode 'ghostel-mode)
    (setq-local ghostel--input-mode 'semi-char)
    (insert "some terminal output")
    (goto-char 1)
    (push-mark (point-max) t t)
    (setq calls-before +cc-test--ghostel-copy-mode-calls)
    (setq call (+cc-test--dispatch)))
  (defvar +cc-test--ghostel-switch-call call)
  (defvar +cc-test--ghostel-switch-invoked
    (= +cc-test--ghostel-copy-mode-calls (1+ calls-before)))
  (kill-buffer buf))

;; --- scenario 5: simulated ghostel buffer, already in copy-mode ---
(let* ((buf (generate-new-buffer "*ghostel: build 2*"))
       (call nil)
       (calls-before 0))
  (with-current-buffer buf
    (setq-local major-mode 'ghostel-mode)
    (setq-local ghostel--input-mode 'copy)
    (insert "some terminal output")
    (goto-char 1)
    (push-mark (point-max) t t)
    (setq calls-before +cc-test--ghostel-copy-mode-calls)
    (setq call (+cc-test--dispatch)))
  (defvar +cc-test--ghostel-no-switch-call call)
  (defvar +cc-test--ghostel-no-switch-skipped
    (= +cc-test--ghostel-copy-mode-calls calls-before))
  (kill-buffer buf))

;; --- scenario 6: simulated non-ghostel non-file buffer (e.g. eshell) ---
(let* ((buf (generate-new-buffer "*eshell: no ghostel*"))
       (call nil)
       (calls-before 0))
  (with-current-buffer buf
    ;; major-mode stays fundamental-mode: not derived from `ghostel-mode'.
    (insert "eshell output")
    (goto-char 1)
    (push-mark (point-max) t t)
    (setq calls-before +cc-test--ghostel-copy-mode-calls)
    (setq call (+cc-test--dispatch)))
  (defvar +cc-test--non-ghostel-call call)
  (defvar +cc-test--non-ghostel-switch-never-invoked
    (= +cc-test--ghostel-copy-mode-calls calls-before))
  (kill-buffer buf))

;; --- assertions ---
(let ((checks
       `(("file-backed buffer: stub send was called"
          . ,(not (null +cc-test--file-backed-call)))
         ("file-backed buffer: send saw the real file's own path"
          . ,(equal (and +cc-test--file-backed-call
                         (file-truename (plist-get +cc-test--file-backed-call :file)))
                    +cc-test--file-backed-path))
         ("file-backed buffer: no temp dir was created for this call"
          . ,+cc-test--dir-untouched-after-file-backed)

         ("non-file buffer + region: stub send was called"
          . ,(not (null +cc-test--nonfile-call)))
         ("non-file buffer + region: a temp file was created"
          . ,(and +cc-test--nonfile-temp-file
                  (file-exists-p +cc-test--nonfile-temp-file)))
         ("non-file buffer + region: temp file name derived from buffer name"
          . ,(and +cc-test--nonfile-temp-file
                  (string-match-p "ghostel_.*npm.*run.*build"
                                   (file-name-nondirectory +cc-test--nonfile-temp-file))))
         ("non-file buffer + region: temp file name carries a timestamp"
          . ,(and +cc-test--nonfile-temp-file
                  (string-match-p "[0-9]\\{8\\}T[0-9]\\{6\\}"
                                   (file-name-nondirectory +cc-test--nonfile-temp-file))))
         ("non-file buffer + region: temp file content is exactly the captured region"
          . ,(and +cc-test--nonfile-temp-file
                  (equal (with-temp-buffer
                           (insert-file-contents +cc-test--nonfile-temp-file)
                           (buffer-string))
                         +cc-test--nonfile-expected-text)))
         ("non-file buffer + region: send saw the temp file as its own file path"
          . ,(equal (and +cc-test--nonfile-call
                         (file-truename (plist-get +cc-test--nonfile-call :file)))
                    (and +cc-test--nonfile-temp-file
                         (file-truename +cc-test--nonfile-temp-file))))
         ("non-file buffer + region: send's region spans the whole temp file"
          . ,(and +cc-test--nonfile-call
                  (equal (plist-get +cc-test--nonfile-call :content)
                         +cc-test--nonfile-expected-text)
                  (= (plist-get +cc-test--nonfile-call :region-beg) 1)
                  (= (plist-get +cc-test--nonfile-call :region-end)
                     (1+ (length +cc-test--nonfile-expected-text)))))

         ("non-file buffer, no region: stub send was not called"
          . ,(null +cc-test--no-region-call))
         ("non-file buffer, no region: no temp file was created"
          . ,+cc-test--no-region-file-count-unchanged)

         ("ghostel buffer not in copy/emacs mode: copy-mode switch was triggered"
          . ,+cc-test--ghostel-switch-invoked)
         ("ghostel buffer not in copy/emacs mode: send was still called after the switch"
          . ,(not (null +cc-test--ghostel-switch-call)))

         ("ghostel buffer already in copy-mode: no redundant switch"
          . ,+cc-test--ghostel-no-switch-skipped)
         ("ghostel buffer already in copy-mode: send was still called"
          . ,(not (null +cc-test--ghostel-no-switch-call)))

         ("non-ghostel non-file buffer: ghostel copy-mode switch never invoked"
          . ,+cc-test--non-ghostel-switch-never-invoked)
         ("non-ghostel non-file buffer: send was still called (generic non-file path)"
          . ,(not (null +cc-test--non-ghostel-call)))))
      (failed nil))
  (dolist (c checks)
    (unless (cdr c) (push (car c) failed)))
  (when (and (boundp '+claude-code-ide--temp-file-dir)
             +claude-code-ide--temp-file-dir
             (file-directory-p +claude-code-ide--temp-file-dir))
    (delete-directory +claude-code-ide--temp-file-dir t))
  (if failed
      (error "FAILED: %s" (string-join (nreverse failed) "; "))
    (message "claude-code buffer-ref OK — %d checks passed" (length checks))))
