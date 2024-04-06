(local cmp (require :cmp))
(local cmp-git (require :cmp_git))
(local lspkind (require :lspkind))
(local luasnip (require :luasnip))

(set vim.opt.completeopt [:menu :menuone :noselect])

(comment (vim.opt.completeopt:get))

(fn expand-snippet [args]
  (luasnip.lsp_expand args.body))

(local lspkind-format (lspkind.cmp_format {:mode :symbol_text :preset :codicons} :maxwidth 50))

(fn format-completion
  [entry vim-item]
  (let [kind (lspkind-format entry vim-item)
        [kind-label menu] (vim.split kind.kind "%s" {:trimempty true})]
    (set kind.kind (.. " " kind-label " "))
    (set kind.menu (.. "    (" menu ")"))
    kind))

(fn get-line-str
  [line col]
  (-?> (vim.api.nvim_buf_get_lines 0 (- line 1) line true)
       (. 1)
       (: :sub col col)
       (: :match "%s")))

(fn has-words-before?
  []
  (let [(line col) (unpack (vim.api.nvim_win_get_cursor 0))]
    (and (not (= col 0))
         (= (get-line-str line col) nil))))

(cmp.setup {:snippet {:expand expand-snippet}
            :mapping {:<C-Space> (cmp.mapping.complete)
                      :<CR> (cmp.mapping.confirm {:select false})
                      ;; :<Tab> (cmp.mapping.select_next_item)
                      :<Tab>   (cmp.mapping
                                 (fn [fallback]
                                   (if 
                                     (cmp.visible)                (cmp.select_next_item)
                                     (luasnip.expand_or_jumpable) (luasnip.expand_or_jump)
                                     (has-words-before?)          (cmp.complete)
                                     (fallback))))
                                     
                      :<S-Tab> (cmp.mapping
                                 (fn [fallback]
                                   (if 
                                     (cmp.visible) (cmp.select_prev_item)
                                     (luasnip.jumpable -1) (luasnip.jump -1)
                                     (fallback))))
                      :<C-b> (cmp.mapping.scroll_docs -4)
                      :<C-f> (cmp.mapping.scroll_docs 4)
                      :<C-g> (cmp.mapping.abort)}
            :formatting {:fields ["kind" "abbr" "menu"]
                         :format format-completion}
            :sources (cmp.config.sources [{:name :nvim_lsp}
                                          {:name :luasnip}
                                          {:name :cmp_git}
                                          {:name :buffer}
                                          {:name :nvim_lsp_signature_help}
                                          {:name :orgmode}
                                          {:name :path}])})

(cmp.setup.filetype :gitcommit
                    {:sources (cmp.config.sources [{:name :cmp_git}
                                                   {:name :buffer}])})

(cmp.setup.cmdline "/" {:mapping (cmp.mapping.preset.cmdline)
                        :sources [{:name :buffer}]})

(cmp.setup.cmdline ":"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources (cmp.config.sources [{:name :path}
                                                  {:name :cmdline}])})

