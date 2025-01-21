;; cspell:disable
(local config-paths (require :j.config.paths))
(local lazypath (.. (vim.fn.stdpath :data) "/lazy/lazy.nvim"))

(vim.opt.rtp:prepend lazypath)
(local lazy (require :lazy))

(lazy.setup
 [{1 "folke/which-key.nvim"
   :config #(let [which-key (require :which-key)]
              (which-key.setup))}

  {1 :ahmedkhalf/project.nvim
   :config #(let [project-nvim (require :project_nvim)]
              ;; Ignoring null-ls as it seems attached to main project
              (project-nvim.setup {:ignore_lsp [:null-ls]}))}

  {1 :gbprod/yanky.nvim
   :config #(let [yanky (require :yanky)]
              (yanky.setup))}

  {1 :nvim-telescope/telescope.nvim
   :dependencies [:nvim-lua/plenary.nvim
                  :nvim-telescope/telescope-file-browser.nvim
                  :nvim-telescope/telescope-ui-select.nvim
                  :kyazdani42/nvim-web-devicons
                  :gbprod/yanky.nvim
                  :debugloop/telescope-undo.nvim]
   :config #(require :j.nvim.plugins.telescope)}

  :shoumodip/nvim-literate

  ; {1 :alexghergh/nvim-tmux-navigation
  ;  :config #(let [tmux (require :nvim-tmux-navigation)]
  ;             (tmux.setup {:disable_when_zoomed true}))}

  {1 :HiPhish/rainbow-delimiters.nvim
   :config #(let [rainbow (require :rainbow-delimiters.setup)]
              (rainbow.setup))}

  {1 :nvim-treesitter/nvim-treesitter
   :dependencies [:nvim-treesitter/nvim-treesitter-context]
   :build ":TSUpdate"
   :config #(let [ts-cfg (require :nvim-treesitter.configs)
                  ts-ctx (require :treesitter-context)
                  parsers (require :nvim-treesitter.parsers)
                  parser-cfg (parsers.get_parser_configs)]
              (ts-cfg.setup {:sync_install true
                             :auto_install true
                             :highlight {:enable true}
                             :indent {:enable true}})
              (ts-ctx.setup)
              (set parser-cfg.markdown.filetype_to_parsername
                   :octo))}

  :nvim-treesitter/nvim-treesitter

  {1 :nvim-orgmode/orgmode
   :after [:nvim-treesitter]
   :config #(require :j.nvim.plugins.org)}

  {1 :nvim-orgmode/orgmode
   :after [:nvim-treesitter/nvim-treesitter]
   :config #(require :j.nvim.plugins.org)}

  {1 :uga-rosa/ccc.nvim
   :config #(let [ccc (require :ccc)]
              (ccc.setup {:bar_char "█"
                          :default_color "#00ffcc"
                          :toggle_alpha true
                          :inputs [ccc.input.hsl
                                   ccc.input.rgb
                                   ccc.input.cmyk]
                          :outputs [ccc.output.hex
                                    ccc.output.css_rgb
                                    ccc.output.css_hsl]}))}


  :AndrewRadev/bufferize.vim

  {1 :Olical/conjure
   :config #(do
              (tset vim.g "conjure#mapping#log_split" "l-")
              (tset vim.g "conjure#mapping#log_vsplit" "l/"))}

  ; {1 :guns/vim-sexp
  ;  :config #(set vim.g.sexp_filetypes "")}

  {1 :julienvincent/nvim-paredit
   :after [:Olical/conjure]
   :config #(require :j.nvim.plugins.clojure)}
              ; (vim.keymap.set :n "<leader>kW" (sexp "<Plug>(sexp_splice_list)")
              ;                 {:desc "splice"})
              

  {1 :numToStr/Comment.nvim
   :config #(let [cmnt (require :Comment)]
              (cmnt.setup {:padding true
                           :sticky true
                           :mappings {:basic true
                                      :extra true
                                      :extended true}}))}

  {1 :williamboman/mason.nvim
   :dependencies [:nvim-lspconfig]
   :config #(let [mason (require :mason)]
              (mason.setup))}

  {1 :williamboman/mason-lspconfig.nvim
   :dependencies [:mason.nvim
                  :nvim-lspconfig]
   :config #(let [masonlsp (require :mason-lspconfig)]
              (masonlsp.setup {:automatic_installation true}))}

  {1 :hrsh7th/nvim-cmp
   :dependencies [:hrsh7th/cmp-nvim-lsp
                  :hrsh7th/cmp-buffer
                  :hrsh7th/cmp-path
                  :hrsh7th/cmp-cmdline
                  :hrsh7th/cmp-git
                  :hrsh7th/cmp-nvim-lsp-signature-help
                  :onsails/lspkind.nvim
                  {1 :L3MON4D3/LuaSnip
                   :version :v1.*}
                  :nvim-lua/plenary.nvim]
   :config #(require :j.nvim.plugins.cmp)}

  {1 :neovim/nvim-lspconfig
   :dependencies [:nvim-cmp
                  :nvim-notify
                  :lspsaga.nvim
                  :none-ls.nvim]
   :config #(require :j.nvim.plugins.lsp)}

  {1 :NeogitOrg/neogit
   :dependencies [:nvim-lua/plenary.nvim
                  :sindrets/diffview.nvim
                  :nvim-telescope/telescope.nvim
                  :ibhagwan/fzf-lua]
   :config #(let [neogit (require :neogit)]
              (neogit.setup {:use_magit_keybindings true}))}

  {1 :pwntester/octo.nvim
   :dependencies [:nvim-lua/plenary.nvim
                  :nvim-telescope/telescope.nvim
                  :kyazdani42/nvim-web-devicons]
   :after [:telescope.nvim]
   :config #(let [octo (require :octo)]
              (octo.setup))}

  {1 :lewis6991/gitsigns.nvim
   :config #(let [gitsigns (require :gitsigns)]
              (gitsigns.setup))}

  {1 :nvimtools/none-ls.nvim
   :dependencies [:lewis6991/gitsigns.nvim
                  :nvim-lua/plenary.nvim
                  :davidmh/cspell.nvim]
   :config #(require :j.nvim.plugins.null-ls)}

  {1 :folke/trouble.nvim
   :require [:kyazdani42/nvim-web-devicons]
   :config #(let [trouble (require :trouble)]
              (trouble.setup))}

  {1 :rcarriga/nvim-notify
   :config #(let [notify (require :notify)] 
              (notify.setup {:background_colour "#000000"})
              (set vim.notify notify))}

  {1 :nvimdev/lspsaga.nvim
   :branch :main
   :config #(let [lspsaga (require :lspsaga)]
              (lspsaga.setup
                {:finder_action_keys {:open "<cr>"
                                      :vsplit "/"
                                      :split "-"}}))}
  {1 :AckslD/nvim-FeMaco.lua
   :config #(let [femaco (require :femaco)]
              (femaco.setup))}

  :sakhnik/nvim-gdb

  :tpope/vim-repeat

  {1 :kylechui/nvim-surround
   :config #(let [surround (require :nvim-surround)]
              (surround.setup))}

  {1 "stevearc/dressing.nvim"
   :config #(let [dressing (require :dressing)]
              (dressing.setup {:select {:enabled false}}))}

  ; {1 "andrewferrier/wrapping.nvim"
  ;  :config #(let [wrapping (require :wrapping)]
  ;             (wrapping.setup
  ;               {:auto_set_mode_filetype_allowlist [:asciidoc
  ;                                                   :gitcommit
  ;                                                   :mail
  ;                                                   :markdown
  ;                                                   :norg
  ;                                                   :org
  ;                                                   :tex]}))}

  {1 "seblj/nvim-tabline"
   :dependencies ["kyazdani42/nvim-web-devicons"]
   :config #(let [tabline (require :tabline)]
              (tabline.setup
                {}))}

  {1 "soywod/himalaya"
   :dependencies [:nvim-telescope/telescope.nvim]}

  {1 "GnikDroy/projections.nvim"
   :dependencies [:nvim-telescope/telescope.nvim]
   :config #(require :j.nvim.plugins.projections)}

  {1 "debugloop/telescope-undo.nvim"
   :dependencies [:nvim-telescope/telescope.nvim]
   :config #(let [telescope (require :telescope)]
              (telescope.load_extension "undo"))}

  {1 "LukasPietzschmann/telescope-tabs"
   :dependencies [:nvim-telescope/telescope.nvim]
   :config #(let [telescope (require :telescope)
                  tabs (require :telescope-tabs)]
              (telescope.load_extension "telescope-tabs")
              (tabs.setup {}))}

  "m4xshen/autoclose.nvim"

  {1 "jonsmithers/vim-html-template-literals"
   :config #(do
              (set vim.g.htl_all_templates 1))}

  {1 "ray-x/lsp_signature.nvim"
   :event :VeryLazy
   :opts {}
   :config (fn [_ opts]
             (let [lsp-sig (require :lsp_signature)]
               (lsp-sig.setup opts)))}
  {1 "rescript-lang/vim-rescript"
   :tag "v2.1.0"
   :ft "rescript"}

  {1 "swaits/zellij-nav.nvim"
   :lazy true
   :event :VeryLazy
   :cond (= (os.getenv "ZELLIJ") "0")
   :keys [[:<c-h> "<cmd>ZellijNavigateLeftTab<cr>" 
           {:silent true
            :desc "Navigate left or tab"}]
          [:<c-j> "<cmd>ZellijNavigateDown<cr>" 
           {:silent true
            :desc "Navigate down"}]
          [:<c-k> "<cmd>ZellijNavigateUp<cr>" 
           {:silent true
            :desc "Navigate up"}]
          [:<c-l> "<cmd>ZellijNavigateRightTab<cr>" 
           {:silent true
            :desc "Navigate right or tab"}]]
   :opts {}}]
  

 {:dev {:path (.. config-paths.nix-pack-path "/pack/myNeovimPackages/start")
        :patterns ["."]
        :fallback true}
  :performance {:reset_packpath true
                :cache {:enabled true}
                :rtp {:reset true}}})

(vim.opt.rtp:prepend config-paths.nix-pack-path)
(vim.opt.packpath:prepend config-paths.nix-pack-path)

"
Solution came indirectly to load packakge plugins from nix:
https://github.com/folke/lazy.nvim/issues/402#issue-1534054767

If this ends up not working, it may be better to use the nix pack path as the
dev directory.
"
(vim.cmd "packloadall")

(comment
  (let [neogit (require :neogit)]
    (neogit.setup {:use_magit_keybindings true}))
  (os.getenv "ZELLIJ"))

{}
