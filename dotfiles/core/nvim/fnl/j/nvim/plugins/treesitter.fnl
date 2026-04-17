(local languages [:clojure :elixir :fennel :heex :python :rust :ecma :typescript :markdown :gitcommit])

(let [ts (require :nvim-treesitter)]
  (ts.install languages))

(vim.api.nvim_create_autocmd
  :FileType
  {:pattern languages
   :callback (fn [args]
               (vim.treesitter.start)
               (set vim.bo.indentexpr "v:lua.require'nvim-treesitter'.indentexpr()"))})
