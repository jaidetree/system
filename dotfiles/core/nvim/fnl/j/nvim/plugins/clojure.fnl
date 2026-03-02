(local paredit (require :nvim-paredit))


(print (fennel.view vim.g.clojure_fuzzy_indent_pattern))

;; Conjure
(tset vim.g "conjure#mapping#log_split" "l-")
(tset vim.g "conjure#mapping#log_vsplit" "l/")

(set vim.g.clojure_fuzzy_indent 1)
(set vim.g.clojure_fuzzy_indent_patterns 
     ["^with" "^def" "^let"
      "^box" "^h-box" "^v-box" 
      "^fn\\*" "^when-" "are"])


(fn noop 
  []
  (print "nvim-paredit feature not implemented"))

(paredit.setup
  {:use_default_keys false
   :filetypes [:clojure]
   :indent {:enabled true}})

(fn wrap
  [start-char end-char]
  (fn []
    (paredit.cursor.place_cursor
      (paredit.wrap.wrap_element_under_cursor start-char end-char)
      {:placement :inner_start
       :mode :insert})))

(local api paredit.api)

(vim.keymap.set :n :<leader>k== noop {:desc :indent})
(vim.keymap.set :n :<leader>k=- noop {:desc "indent top"})
(vim.keymap.set :n :<leader>kw (wrap "(" ")") {:desc "wrap ("})
(vim.keymap.set :n "<leader>k[" (wrap "[" "]") {:desc "wrap ["})
(vim.keymap.set :n "<leader>k{" (wrap "{" "}") {:desc "wrap {"})
(vim.keymap.set :n :<leader>kr api.raise_element {:desc :raise})
(vim.keymap.set :n :<leader>kc noop {:desc :convolute})
(vim.keymap.set :n :<leader>ks api.slurp_forwards {:desc :slurp})
(vim.keymap.set :n :<leader>kS api.slurp_backwards
                {:desc "slurp backward"})
(vim.keymap.set :n :<leader>kb api.barf_forwards
                {:desc "barf"})
(vim.keymap.set :n :<leader>kB api.barf_backwards
                {:desc "barf backward"})
(vim.keymap.set :n :<leader>kk api.move_to_prev_element_head
                {:desc "prev element"})
(vim.keymap.set :n :<leader>kK noop
                {:desc "prev top element"})
(vim.keymap.set :n :<leader>kj api.move_to_next_element_head
                {:desc "next element"})
(vim.keymap.set :n :<leader>kJ noop
                {:desc "next top element"})
(vim.keymap.set :n :<leader>kh noop
                {:desc "back element"})
(vim.keymap.set :n :<leader>kl noop
                {:desc "next element"})
(vim.keymap.set :n :<leader>kt api.drag_element_backwards
                {:desc "transition"})
(vim.keymap.set :n :<leader>kT api.drag_element_forwards
                {:desc "transition forward"})
(vim.keymap.set :n "<leader>kW" noop {:desc "splice"})


(comment
 (msg "Test"))
