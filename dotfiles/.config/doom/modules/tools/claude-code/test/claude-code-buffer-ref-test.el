;;; tools/claude-code/test/claude-code-buffer-ref-test.el -*- lexical-binding: t; -*-
;; Run: emacs -Q --batch -l ~/.config/doom/modules/tools/claude-code/test/claude-code-buffer-ref-test.el

;; --- the real code under test: no external deps, no live MCP session ---
(load (expand-file-name "../buffer-ref.el" (file-name-directory load-file-name)))

;; Batch mode starts with `transient-mark-mode' off, so `use-region-p' (which
;; the code under test relies on) would never see an active region.
(transient-mark-mode 1)

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

;; --- scenario 4: periodic sweep removes stale files, spares fresh ones ---
(let* ((sweep-dir (make-temp-file "claude-code-buffer-ref-test-sweep-" t))
       (stale-file (expand-file-name "stale-ref.txt" sweep-dir))
       (fresh-file (expand-file-name "fresh-ref.txt" sweep-dir))
       (stale-age (+ 60 +claude-code-ide-temp-file-max-age))
       (+claude-code-ide--temp-file-dir sweep-dir))
  (write-region "stale" nil stale-file nil 'silent)
  (write-region "fresh" nil fresh-file nil 'silent)
  (set-file-times stale-file (time-subtract (current-time) (seconds-to-time stale-age)))
  (+claude-code-ide--temp-file-sweep)
  (defvar +cc-test--sweep-removed-stale (not (file-exists-p stale-file)))
  (defvar +cc-test--sweep-kept-fresh (file-exists-p fresh-file))
  (delete-directory sweep-dir t))

;; --- scenario 5: exit-hook cleanup is a no-op when no temp dir was ever
;;     created, and removes the directory when one was ---
(let ((+claude-code-ide--temp-file-dir nil))
  (defvar +cc-test--cleanup-noop-when-nil
    (progn (+claude-code-ide--temp-file-dir-cleanup) t)))

(let* ((dir (make-temp-file "claude-code-buffer-ref-test-cleanup-" t))
       (+claude-code-ide--temp-file-dir dir))
  (+claude-code-ide--temp-file-dir-cleanup)
  (defvar +cc-test--cleanup-removes-dir (not (file-exists-p dir))))

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

         ("sweep: removes a file older than the max age"
          . ,+cc-test--sweep-removed-stale)
         ("sweep: leaves a freshly-written file alone"
          . ,+cc-test--sweep-kept-fresh)
         ("exit-hook cleanup: no-op when no temp dir was ever created"
          . ,+cc-test--cleanup-noop-when-nil)
         ("exit-hook cleanup: removes the temp dir when one exists"
          . ,+cc-test--cleanup-removes-dir)))
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
