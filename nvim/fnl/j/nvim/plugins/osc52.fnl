(local osc (require :osc52))

(fn copy
  []
  (if (and (= vim.v.event.operator :y)
           (= vim.v.event.regname :+))
    (osc.copy_register :+)))

(vim.api.nvim_create_autocmd :TextYankPost {:callback copy})
