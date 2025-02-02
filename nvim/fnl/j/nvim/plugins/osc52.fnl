(local osc (require :osc52))

(fn copy
  []
  (let [{: operator : regname} vim.v.event]
    (when (and (= operator :y)
               (or (= regname :+)
                   (= regname "")))
      (osc.copy_register :+)))
  true)

(vim.api.nvim_create_augroup :JOSC52 {:clear true})
(vim.api.nvim_create_autocmd
  :TextYankPost
  {:callback copy
   :pattern "*"
   :group :JOSC52})

(vim.keymap.set
  :n
  :<Leader>yy #(osc.copy_register :+)
  {:remap false
   :desc "Copy + to osc52"})

(comment
  (osc.copy_register :+))
