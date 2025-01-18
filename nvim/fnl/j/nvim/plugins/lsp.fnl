(local lspcfg (require :lspconfig))
(local twcfg (require :lspconfig.configs.tailwindcss))
(local cmp-nvim-lsp (require :cmp_nvim_lsp))
       

(local wk (require :which-key))
(local async (require :plenary.async))
(local util (require :vim.lsp.util))
(local notify (require :notify))

(local lsp-sig (require :lsp_signature))

(local capabilities (vim.tbl_deep_extend
                      :force
                      (vim.lsp.protocol.make_client_capabilities)
                      (cmp-nvim-lsp.default_capabilities)
                      {:workspace {:didChangeWatchedFiles {:dynamicRegistration true}}}))

(local augroup (vim.api.nvim_create_augroup "LspFormatting" {}))

(comment (notify :test))

(fn parse-markdown-links []
  nil)

                   
(local flags {:debounce_text_changes 150})
(local opts {:noremap true :silent true})

(fn map 
  [lhs rhs ...]
  "
  Map to <leader>c prefix for code actions
  "
  (let [args [...]
        custom-opts (or (. args 1) {})]
    (vim.keymap.set :n (.. :<leader>c lhs) rhs
                    (vim.tbl_extend :force opts custom-opts))))

(wk.add [{1 :<leader>l :group :+lsp}])

(map :j "<cmd>Lspsaga finder<cr>" {:desc "Goto definition"})
(map :d "<cmd>Lspsaga peek_definition<cr>" {:desc "Peek definition"})
(map :D vim.lsp.buf.references {:desc "Goto references"})
(map :i vim.lsp.buf.implementation {:desc "Goto implementation"})
(map :h vim.lsp.buf.signature_help {:desc "Signature help"})
(map :t vim.lsp.buf.type_definition {:desc "Goto type definition"})
(map :r vim.lsp.buf.rename {:desc :Rename})
(map :K vim.lsp.buf.hover {:desc :Documentation})
;; (map :K hover.hover {:desc :Documentation})
;; TODO: Replace with telescope UI command
(map :a vim.lsp.buf.code_action {:desc "Code Actions"})
(map :f vim.lsp.buf.format {:desc :Format})
(map :wa vim.lsp.buf.add_workspace_folder {:desc "Create folder"})
(map :wr vim.lsp.buf.remove_workspace_folder {:desc "Remove folder"})
(map :wl #(print (vim.inspect (vim.lsp.buf.list_workspace_folders))))

(wk.add [{1 :<leader>lg :group :+goto}])

(map :gd vim.lsp.buf.definition)
(map :gl vim.lsp.buf.declaration)


(vim.keymap.set 
  :n :<leader>le "<cmd>Trouble diagnostics toggle<cr>"
  (vim.tbl_extend :force opts {:desc "Open diagnostics"}))

(vim.keymap.set 
  :n :<leader>lq "<cmd>Trouble loclist toggle<cr>"
  (vim.tbl_extend :force opts {:desc "Location list"}))


;; Other Bindings

(vim.keymap.set :n "[d" vim.diagnostic.goto_prev
                (vim.tbl_extend :force opts {:desc "Prev diagnostic issue"}))

(vim.keymap.set :n "]d" vim.diagnostic.goto_next
                (vim.tbl_extend :force opts {:desc "Next diagnostic issue"}))

(vim.keymap.set :n :<leader>cf vim.lsp.buf.format
                (vim.tbl_extend :force opts {:desc :Format}))

;; (vim.keymap.set :n :<leader>ce vim.diagnostic.open_float
;;                 (vim.tbl_extend :force opts {:desc "Diagnostics"}))

(vim.keymap.set :n :<leader>ce "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"
                (vim.tbl_extend :force opts {:desc :Diagnostics}))

(fn quiet-hover-handler 
  [_ result ctx config]
  "Duplicates original implementation but is quieter about errors as this is
  displayed automatically when moving the cursor."
  (let [config (or config {})
        client (vim.lsp.get_client_by_id ctx.client_id)]
    (when (and result result.contents)
      (let [markdown-lines (-> result.contents
                               (util.convert_input_to_markdown_lines)
                               (util.trim_empty_lines))]
        (when (not (vim.tbl_isempty markdown-lines))
          (util.open_floating_preview markdown-lines :markdown config nil))))))


;; Create a quieter handler for hover when automating

(fn quiet-hover
  []
  (let [params (util.make_position_params)]
    (vim.lsp.buf_request 0 :textDocument/hover params 
                         (vim.lsp.with 
                           quiet-hover-handler
                           {:border :rounded
                            :width 80
                            :wrap_at 78
                            :stylize_markdown true
                            :close_events [:CursorHold :BufEnter :BufLeave]
                            :focusable false
                            :focus false}))))

(fn formatting-enabled?
  [client]
  (and (not= client.name :tsserver)
       (not vim.b.noformat)))

(fn on-attach 
  [client bufnr]
  (lsp-sig.on_attach {:bind true
                      :handler_opts {:border :rounded}} bufnr)
  (when (= client.name :tsserver)
    (set client.server_capabilities.documentFormattingProvider false))
  (when (client.supports_method "textDocument/formatting")
    (vim.api.nvim_clear_autocmds {:group augroup
                                  :buffer bufnr})
    (vim.api.nvim_create_autocmd :BufWritePre
                                 {:group augroup
                                  :buffer bufnr
                                  :callback (fn []
                                              (vim.lsp.buf.format {:bufnr bufnr
                                                                   :filter formatting-enabled?}))}))
  (vim.keymap.set :n :<C-Space> vim.lsp.buf.signature_help {:desc "Signature help"})
  (vim.keymap.set :n :<C-.> vim.lsp.buf.signature_help {:desc "Signature help"}))

;; Update global handlers
(local handlers
  {:textDocument/hover 
   (vim.lsp.with 
     vim.lsp.handlers.hover
     {:border :rounded
      :width 80
      :wrap_at 78
      :stylize_markdown true})

   :textDocument/signatureHelp
   (vim.lsp.with
     vim.lsp.handlers.signature_help
     {:border :rounded
      :width 80
      :wrap_at 78
      :stylize_markdown true
      :focusable false
      :focus false})})

(lspcfg.ts_ls.setup 
 {: capabilities
  : flags
  : handlers
  :on_attach on-attach
  :init_options {:hostInfo :neovim}})

(lspcfg.rescriptls.setup 
  {: capabilities
   : flags
   : handlers
   :on_attach on-attach})

(lspcfg.clojure_lsp.setup 
  {: capabilities 
   : flags
   : handlers
   :on_attach on-attach}) 

(lspcfg.tailwindcss.setup 
  {: capabilities
   : flags
   : handlers
   :on_attach on-attach
   :filetypes (vim.list_extend [:clojure]
                               twcfg.default_config.filetypes)})

(lspcfg.ocamllsp.setup
  {: capabilities
   : flags
   : handlers
   :on_attach on-attach})

(lspcfg.standardrb.setup
  {: capabilities
   : flags
   : handlers
   :on_attach on-attach})

(lspcfg.nil_ls.setup 
  {: capabilities
   : flags
   : handlers
   :on_attach on-attach
   :settings {:nil {:formatting {:command ["nixpkgs-fmt"]}}}})

(comment (vim.inspect twcfg)
 (lsp.buf_is_attached 0)
 nil)

(comment
  (require :lsp))
