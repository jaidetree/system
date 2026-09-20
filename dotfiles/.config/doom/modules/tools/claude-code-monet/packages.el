;; -*- no-byte-compile: t; -*-
;;; tools/claude-code-monet/packages.el

(package! claude-code
  :recipe (:host github :repo "stevemolitor/claude-code.el"))

(package! monet
  :recipe (:host github :repo "stevemolitor/monet"))
