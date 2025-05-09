;; (local packer (require :j.nvim.packer))
(local {:core c :string s} (require :j.nvim.utils))

;; Just exploring writing a custom statusline from scratch
;; (require :j.nvim.statusline)

(fn kbd [key-str]
  "Helper to escape termcodes like <Space> to normal values"
  (vim.api.nvim_replace_termcodes key-str true false true))

;; (vim.cmd.colorscheme :catppuccin-mocha)
(set vim.g.mapleader (kbd :<Space>))
(set vim.g.maplocalleader (kbd :<Space>m))


;; Replacing this with project nvim
;; (set vim.opt.autochdir true)

(comment
  (vim.opt.rtp:get))

;; (print "before\n")
;; (print (fennel.view (vim.opt.rtp:get)))

(fn ask-to-confirm
  [prompt default-value yes-values]
  (let [yes-values (or yes-values [:y :yes])
        default-value (or default-value "")
        confirmation (string.lower (vim.fn.input prompt default-value))]
    (if (= (string.len confirmation) 0)
      false
      (do
        (each [_ v (ipairs yes-values)]
          (when (= v confirmation)
            (lua "return v")))
        false))))

(fn create-new-file
  []
  (let [filename (vim.api.nvim_buf_get_name 0)]
    (when (= 0 (vim.fn.filereadable filename))
      (let [dirname  (vim.fs.dirname filename)]
        (vim.fn.mkdir dirname "p")))))

(vim.api.nvim_create_augroup :JCreateNewFile {:clear true})
(vim.api.nvim_create_autocmd
  :BufWritePre
  {:group :JCreateNewFile
   :callback create-new-file})

;; Packages
(require :j.nvim.plugins)
(vim.cmd.colorscheme :catppuccin-mocha)

; (print "after\n")
; (print (fennel.view (vim.opt.rtp:get)))

(local statusline (require :j.nvim.statusline))

(statusline.setup)


;; Advanced setup

(local wk (require :which-key))

;; Code & LSP

(wk.add [{1 :<leader>c :group :+code}])

(wk.add [{1 :<leader>cw :group :+workspace}])

(comment ;; Merges create new tables
  (let [tbl-a {:a 1}]
    {:merged (vim.tbl_extend :force tbl-a {:b 1}) :orig tbl-a}))

;; Utils

(fn lisp-filetype?
  [filetype]
  (let [filetypes (or (. vim.g "conjure#filetypes") {})]
    (vim.tbl_contains filetypes filetype)))

(comment (lisp-filetype? :fennel)
  (lisp-filetype? :rust))

;; Custom commands

(fn reload-statusline
  []
  (tset package.loaded :j.nvim.statusline nil)
  (let [sl (require :j.nvim.statusline)]
    (sl.setup)))

(vim.api.nvim_create_user_command :ReloadStatusLine reload-statusline {})

(fn reload-config []
  (let [modules []]
   (each [module-name exports (pairs package.loaded)]
     (when (and (s.starts-with? module-name :j.nvim)
                (not= module-name :fennel)
                (not= module-name :j.nvim.plugins))
       (table.insert modules module-name)
       (tset package.loaded module-name nil)))
   (require :j.nvim.core)
   (each [_i module-name (ipairs modules)]
     (when (not= module-name :j.nvim.core)
       (require module-name)))
   (print "Reloaded config")))

(comment
  (require "init")
  (reload-config)
  package.loaded.fennel)

(vim.api.nvim_create_user_command :ReloadConfig reload-config {})
;; (vim.api.nvim_create_user_command :ReloadConfig (fn [] nil) {})


(fn fnlfile
  [{:fargs [filepath]}]
  (fennel.doolie filepath))

(vim.api.nvim_create_user_command :FnlFile fnlfile {:nargs 1 :complete :file})

(comment
 (vim.api.nvim_create_user_command
  :TelescopeFileMenu
  (fn [{:fargs [filepath]}]
    ((. vim.cmd :Telescope) :file_menu (.. "filepath=" filepath)))

  {:nargs 1
   :complete :file}))


;; Keybindings

(vim.keymap.set :n :<Leader><Leader> "<cmd>Telescope commands<cr>" {:desc :M-x})

(vim.keymap.set :n "<Leader>:" ":" {:desc :Cmd})

(vim.keymap.set :n :<Esc><Esc> :<cmd>nohl<cr> {:silent true})

;; Replace with some kind of fuzzy finder thing
(vim.keymap.set [:n :v :i] :<C-g> :<Esc>)

;; File > Editor

(wk.add [{1 :<leader>fe :group :+editor}])

(vim.keymap.set :n :<Leader>fee "<cmd>FnlFile %<cr>" {:desc "Eval fennel file"})

;; File

(wk.add [{1 :<leader>f :group :+file}])

(vim.keymap.set :n :<Leader>ff "<cmd>Telescope emacs_find_files hidden=true no_ignore=true<cr>"
                {:desc "Find file"})

(vim.keymap.set :n :<Leader>fp
                "<cmd>Telescope emacs_find_files cwd=~/.config/nvim<cr>"
                {:desc "Edit neovim config"})

(vim.keymap.set [:n :v] :<Leader>fs :<cmd>w<cr> {:desc "Save file"})

;; Buffer

(wk.add [{1 :<leader>b :group :+buffer}])

(vim.keymap.set :n :<Leader>bb "<cmd>Telescope telescope-tabs list_tabs<cr>"
                {:desc "Switch tab"})

(vim.keymap.set :n :<Leader>bB "<cmd>Telescope buffers<cr>"
                {:desc "Switch buffer"})

;; Thanks to https://vim.fandom.com/wiki/Deleting_a_buffer_without_closing_the_window
(vim.keymap.set :n :<Leader>bd "<cmd>:bprev<cr><cmd>:bdelete #<cr>"
                {:desc "Delete buffer"})

(vim.keymap.set :n :<Leader>bk "<cmd>:bdelete<cr>"
                {:desc "Kill buffer & window"})

(vim.keymap.set :n :<Leader>bp "<cmd>:bprevious<cr>" {:desc "Previous buffer"})

(vim.keymap.set :n :<Leader>bn "<cmd>:bnext<cr>" {:desc "Next buffer"})

;; Project

(wk.add [{1 :<leader>p :group :+project}])

(vim.keymap.set :n :<Leader>pf "<cmd>Telescope find_files<cr>"
                {:desc "Find project file"})

(vim.keymap.set :n :<Leader>pP "<cmd>Telescope projects<cr>"
                {:desc "Switch project"})

(vim.keymap.set "n" :<Leader>pp "<cmd>Telescope projections<cr>")

;; Org

(wk.add [{1 :<leader>o :group :+org}])

;; Git

(wk.add [{1 :<leader>g :group :+git}])

(vim.keymap.set :n :<leader>gg :<cmd>Neogit<cr>)

;; Help

(wk.add [{1 :<leader>h :name :+help}])

(vim.keymap.set :n :<Leader>hh ":help " {:desc :Help})

(vim.keymap.set :n :<Leader>hr :<cmd>ReloadConfig<cr> {:desc "Reload nvim cfg"})

(vim.keymap.set :n :<Leader>hR "<cmd>ReloadConfig<cr><cmd>Lazy sync<cr>"
                {:desc "Reload cfg + sync"})

(vim.keymap.set :n :<Leader>hm :<cmd>messages<cr> {:desc :messages})

(vim.keymap.set :n :<Leader>hn "<cmd>vert Bufferize nmap<cr>"
                {:desc "normal bindings"})

(vim.keymap.set :n :<Leader>hi "<cmd>vert Bufferize imap<cr>"
                {:desc "insert bindings"})

(vim.keymap.set :n :<Leader>hv "<cmd>vert Bufferize vmap<cr>"
                {:desc "visual bindings"})

(vim.keymap.set :n :<Leader>hs "<cmd>ReloadStatusLine<cr>"
                {:desc "Reload statusline"
                 :noremap true})

;; Help > Plugins

(wk.add [{1 :<leader>hp :group :+plugins}])

(vim.keymap.set :n :<Leader>hpf :<cmd>ReloadFeline<cr> {:desc "Reload Feline"})

;; Insert operations

(wk.add [{1 :i :group :+insert}])

(vim.keymap.set :n :<leader>ic :<cmd>CccPick<cr>
                {:desc "Pick color" :remap false :silent true})

;; Lisp

(wk.add [{1 :<leader>k :group :+lisp}])
(wk.add [{1 :<leader>k= :group :+indent}])

(comment
  (vim.cmd "(sexp_indent)")
  (vim.cmd "<Plug>(sexp_raise_element)"))

(fn sexp
  [cmd]
  (.. "<cmd>ParinferOff<cr>" cmd "<cmd>ParinferOn<cr>"))
   ;(vim.cmd "ParinferOn")))

(comment
  (vim.cmd "execute normal <Plug>(sexp_raise_element)")
  (do
    (vim.cmd "ParinferOff")
    (vim.cmd "execute normal <Plug>(sexp_raise_element)<cr>")
    (vim.cmd "ParinferOn")))

(comment
 nil
 [ 1 2 3]

 nil)


;; Quit

(wk.add {1 :<leader>q :group :+quit})

(vim.keymap.set :n :<Leader>qq :<cmd>quitall<cr> {:silent true})

;; Toggle

(wk.add [{1 :<leader>t :group :+toggle}])
(vim.keymap.set :n :<Leader>tf :<cmd>ToggleFormatting<cr>
                {:silent true :remap false :desc :Auto-formatting})
(vim.keymap.set :n :<Leader>tr
                (fn []
                  (if vim.bo.readonly
                     (set vim.bo.readonly false)
                     (set vim.bo.readonly true)))
                {:silent true :remap false :desc :Readonly})

(fn toggle-line-numbers
  []
  (if vim.o.relativenumber
    (do
      (set vim.o.relativenumber false)
      (set vim.o.number false))
    (do
      (set vim.o.relativenumber true)
      (set vim.o.number true))))

(vim.keymap.set :n :<Leader>tn toggle-line-numbers
                {:remap false :desc "Toggle linenumbers"})
(vim.keymap.set :n :<Leader>tw "<cmd>ToggleWrapMode<cr>"
                {:remap false :desc "Toggle wrapping"})

;; Window

(wk.add [{1 :<leader>h :group :+window}])

(vim.keymap.set :n :<Leader>w- :<cmd>split<cr>
                {:silent true :desc "Split Horizontal"})
(vim.keymap.set :n :<Leader>w/ :<cmd>vsplit!<cr>
                {:silent true :desc "Split Vertical" :noremap true})
(vim.keymap.set :n :<Leader>wd :<cmd>q<cr> {:silent true :desc "Quit Window"})
(vim.keymap.set :n :<Leader>wx :<cmd>bdelete<cr><cmd>q<cr>
                {:desc "Kill window"})
(vim.keymap.set :n :<Leader>w= "<cmd>wincmd =<cr>"
                {:desc "Equalize"})

;; Undo

(vim.keymap.set :n :<leader>u "<cmd>Telescope undo<cr>" {:desc "Undo"})

;; Zellij Navigation

(vim.keymap.set :n :<Leader>wh "<cmd>ZellijNavigateLeftTab<cr>" {:desc "Window left"})
(vim.keymap.set :n :<Leader>wj "<cmd>ZellijNavigateDown<cr>" {:desc "Window down"})
(vim.keymap.set :n :<Leader>wk "<cmd>ZellijNavigateUp<cr>" {:desc "Window up"})
(vim.keymap.set :n :<Leader>wl "<cmd>ZellijNavigateLeftTab<cr>" {:desc "Window right"})
(vim.keymap.set :n :<Leader>w<Space> "<cmd>ZellijNavigateRightTab<cr>" {:desc "Window next"})

;; Yank

(wk.add [{1 :<leader>y :group :+yank}])

(vim.keymap.set [:n :v] :<Leader>yk "<cmd>Telescope yank_history<cr>")

;; Normal bindings

;; Move by visual lines
(vim.keymap.set [:n :v] :j :gj)
(vim.keymap.set [:n :v] :k :gk)

;; OS X Bindings

(vim.keymap.set [:n :v] :<D-s> :<cmd>w<cr>)
(vim.keymap.set [:n :v] :<D-p> "<cmd>Telescope find_files<cr>")
(vim.keymap.set [:n :v] :<D-S-P> "<cmd>Telescope commands<cr>")
(vim.keymap.set [:n :v] :<D-t> :<cmd>tabnew<cr>)
(vim.keymap.set [:n :v] "<D-;>" :gcc {:remap true})

;; Clipboard

(vim.keymap.set [:n :x] :p "<Plug>(YankyPutAfter)")
(vim.keymap.set [:n :x] :P "<Plug>(YankyPutBefore)")
(vim.keymap.set [:n :x] :gp "<Plug>(YankyGPutAfter)")
(vim.keymap.set [:n :x] :gP "<Plug>(YankyGPutBefore)")

(vim.keymap.set :n :<C-n> "<Plug>(YankyCycleForward)")
(vim.keymap.set :n :<C-p> "<Plug>(YankyCycleBackward)")

(vim.keymap.set :i :<D-v> "<Esc><Plug>(YankyPutAfter)")
(vim.keymap.set :v :<D-c> "\"+y")
(vim.keymap.set :c :<D-v> :<C-r>+ {:remap false})


;; Insert bindings

;; Escape shortcut in insert mode

(vim.keymap.set :i :jj :<Esc> {:noremap true})

;; Conjure Evaluation

(wk.add [{1 :<leader>m :group :+mode}])

(wk.add [{1 :<leader>me :group :+eval}])

(wk.add [{1 :<leader>ml :group :+log}
         {1 :e :desc "Log buf"}
         {1 :g :desc "Toggle log"}
         {1 :l :desc "Jump latest"}
         {1 :q :desc "Close log"}
         {1 :r :desc "Reset soft"}
         {1 :R :desc "Reset hard"}
         {1 :s :desc "Log split horizontal"}
         {1 :t :desc "Log tab"}
         {1 :v :desc "Log Split vertical"}])

(fn conjure-bindings
  [{: buf}]
  (vim.keymap.set [:n :i] :<C-c><C-c> :<LocalLeader>er
                  {:desc "Eval top-level form" :remap true :buffer buf})

  (vim.keymap.set [:n :i] :<C-c><C-e> :<LocalLeader>ee
                  {:desc "Eval form at point" :remap true :buffer buf})

  (vim.keymap.set [:n :i] :<C-c><C-f>
                  :<C-c><C-C><cmd>ConjureLogCloseVisible<cr><LocalLeader>lv
                  {:desc "Eval top-level pprint" :remap true :buffer buf})

  (vim.keymap.set [:n :i] :<C-c><C-m> :<LocalLeader>em
                  {:desc "Eval marked" :remap true :buffer buf})

  (vim.keymap.set [:n :i] :<C-c><C-l> :<LocalLeader>eb
                  {:desc "Eval buf" :remap true :buffer buf})

  (vim.keymap.set [:n :i] :<C-c><C-k> :<LocalLeader>ef
                  {:desc "Eval file" :remap true :buffer buf})

  (vim.keymap.set [:n :i] "<C-c>;" :<LocalLeader>ecr
                  {:desc "Eval comment below" :remap true :buffer buf}))

;; Git Commit Bindings

(fn neogit-bindings
  [{: buf}]
  (vim.api.nvim_buf_set_keymap buf :n :<C-c><C-c> "<cmd>wq<cr>"
                  {:desc "Commit" :noremap true})
  (vim.api.nvim_buf_set_keymap buf :n :<C-c><C-k> (.. "<cmd>bdelete! " buf "<cr>")
                  {:desc "Cancel" :noremap true}))


(vim.api.nvim_create_augroup :JConditionalBindings {:clear true})
(vim.api.nvim_create_autocmd
  [:BufEnter :BufWinEnter :BufNew]
  {:group  :JConditionalBindings
   :callback
   (fn [args]
     (if
       (lisp-filetype? vim.bo.filetype) (conjure-bindings args))
     nil)})

(vim.api.nvim_create_augroup :JNeogitBindings {:clear true})
(vim.api.nvim_create_autocmd
  :Filetype
  {:group :JNeogitBindings
   :pattern :NeogitCommitMessage
   :callback neogit-bindings})

(vim.api.nvim_create_augroup :JHelpBindings {:clear true})
(vim.api.nvim_create_autocmd
  :Filetype
  {:group :JHelpBindings
   :pattern :help
   :callback
   (fn [args]
     (vim.keymap.set :n :q "<cmd>q<cr>"
                     {:desc "Quit" :nowait true
                      :remap true :buffer args.buf}))})

(vim.api.nvim_create_augroup :JHimalaya {:clear true})
(vim.api.nvim_create_autocmd
  :Filetype
  {:group :JHimalaya
   :pattern :himalaya
   :callback
   (fn [args]
     nil)})

;; Document Editing

(vim.keymap.set [:n :i] "<C-c>'" :<cmd>FeMaco<cr>)

;; Command line
;; - Gotta have those common emacs bindings

(vim.keymap.set :c :<C-a> :<Home> {:remap false})
(vim.keymap.set :c :<C-e> :<End> {:remap false})
(vim.keymap.set :c :<C-b> :<S-Left> {:remap false})
(vim.keymap.set :c :<C-f> :<S-Right> {:remap false})

;; Custom plugins
;; - These are worth separating from normal plugin setup as these can be
;;   reloaded quickly with `<SPC>hr` vs going through the packer sync
;;   process
(require :j.nvim.plugins.org-tangle)

(comment ;; eval these
  (vim.opt.path:prepend :$HOME/.asdf/shims)
  (vim.opt.path:get)
  (let [telescope (require :telescope)]
    (print (vim.inspect telescope)))
  (print (vim.inspect (vim.opt.filetype:get)))
  (let [ts (require :conjure.tree-sitter)]
    (ts.node->str (ts.get-root)))
  (. vim.g "conjure#mapping#log_split")
  vim.g.conjure#filetypes
  (vim.opt.filetype:get)
  (vim.cmd :!tailwindcss-language-server)
  (vim.opt.path:get)
  (vim.opt.mouse:get)
  vim.g.neovide
  vim.g.neovide_input_use_logo
  vim.g.neovide_cursor_trail_length
  vim.g.neovide_cursor_animation_length
  (or (not (= (vim.api.nvim_buf_get_option 0 :buftype) ""))
      (= (vim.api.nvim_buf_get_name 0) ""))
  (let [sources (require :null-ls.sources)
        ft (vim.api.nvim_buf_get_option 0 :filetype)]
    (vim.inspect (icollect [_ source (ipairs (sources.get_all))]
                   (if (sources.is_available source ft)
                       source))))
  (let [saga (require :lspsaga)]
    (saga.init_lsp_saga))
  (let [client (require :null-ls.client)]
    (print (vim.inspect client))
    (client.supports_method :textDocument/formatting))
  vim.o.wrap
  vim.o.textwidth
  vim.o.linebreak
  nil)
