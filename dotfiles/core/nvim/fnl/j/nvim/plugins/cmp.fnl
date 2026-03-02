(local cmp (require :cmp))
(local luasnip (require :luasnip))

(set vim.opt.completeopt [:menu :menuone :noselect])

(fn expand-snippet [args]
  (luasnip.lsp_expand args.body))

(cmp.setup {:snippet {:expand expand-snippet}
            :completion {:autocomplete false}
            :mapping {:<C-Space> (cmp.mapping.complete)
                      :<CR> (cmp.mapping.confirm {:select false})
                      :<Tab> (cmp.mapping.select_next_item)
                      :<S-Tab> (cmp.mapping
                                 (fn [fallback]
                                   (if 
                                     (cmp.visible) (cmp.select_prev_item)
                                     (luasnip.jumpable -1) (luasnip.jump -1)
                                     (fallback))))
                      :<C-b> (cmp.mapping.scroll_docs -4)
                      :<C-f> (cmp.mapping.scroll_docs 4)
                      :<C-g> (cmp.mapping.abort)}
            :sources (cmp.config.sources [
                                          ;{:name :nvim_lsp_signature_help}]
                                          {:name :nvim_lsp}]
                                         [{:name :luasnip}]
                                         [{:name :path}
                                          {:name :cmp_git}]
                                         [{:name :buffer}])})

(cmp.setup.filetype :gitcommit
                    {:sources (cmp.config.sources [{:name :cmp_git}
                                                   {:name :buffer}])})

(cmp.setup.cmdline "/" {:mapping (cmp.mapping.preset.cmdline)
                        :sources [{:name :buffer}]})

(cmp.setup.cmdline ":"
                   {:mapping (cmp.mapping.preset.cmdline)
                    :sources (cmp.config.sources [{:name :path}
                                                  {:name :cmdline}])})

(comment
  
  (local pattern-utils (require :cmp.utils.pattern))
  (local offset pattern-utils.offset)

  (tset pattern-utils 
        :offset (fn [p text]
                  (print (.. "cmp.utils.pattern " p))
                  (offset p text)))) 
      
