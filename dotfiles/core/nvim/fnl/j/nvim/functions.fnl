(local M {})

(fn M.OpenTrouble
  []
  (let [trouble (require :trouble)]
    (trouble.open)))

(fn M.merge
  [...]
  (vim.tbl_deep_extend :force {} ...))

(comment
  (M.OpenTrouble))

M
