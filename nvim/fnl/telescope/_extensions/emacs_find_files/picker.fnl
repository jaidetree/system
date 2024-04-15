(local utils (require :telescope.utils))
(local make_entry (require :telescope.make_entry))
(local pickers (require :telescope.pickers))
(local sorters (require :telescope.sorters))
(local finders (require :telescope.finders))
(local actions (require :telescope.actions))
(local actions-state (require :telescope.actions.state))
(local {:values conf} (require :telescope.config))
(local telescope-state (require :telescope.state))


(local find-command ["fd" "--color" "never" "--absolute-path" "--full-path" "--fixed-strings" "--ignore-case"])
(local command "fd")

(fn expand-search-dirs
  [search-dirs]
  (icollect 
    [k v (ipairs search-dirs)]
    (utils.path_expand v)))

(fn build-find-command
  [find-command opts]
  (let [command (vim.list_extend [] find-command)
        append-arg #(table.insert command $)]
    (when opts.hidden
      (append-arg "--hidden"))
    (when opts.no_ignore
      (append-arg "--no-ignore"))
    (when opts.no_ignore_parent
      (append-arg "--no-ignore-parent"))
    (when opts.follow
      (append-arg "-L"))
    (comment
     (when opts.search_file
      (append-arg "-g")
      (append-arg (.. "*" opts.search_file "*"))))
    (comment
     (when opts.search_dirs
      (vim.list_extend command opts.search-dirs)))
    command))

(comment
  (build-find-command
    find-command {}))

(comment
  (build-find-command find-command))

(fn normalize-opts
  [opts]
  (let [tbl (vim.tbl_deep_extend :force {} opts)]
    (when opts.search_dirs
      (tset tbl :search_dirs (expand-search-dirs opts.search_dirs)))
    (when opts.cwd
      (tset tbl :cwd (utils.path_expand opts.cwd)))
    ; (when (not opts.initial_mode)
    ;   (set tbl.initial_mode :insert))
    (set tbl.entry_maker (or tbl.entry_maker (make_entry.gen_from_file tbl)))
    tbl))

(fn prompt->find-command
  [command prompt]
  (let [cmd (vim.list_extend [] command)
        [bufnr] (telescope-state.get_existing_prompt_bufnrs)
        picker (actions-state.get_current_picker bufnr)]
    (print "finder: picker._base_path" picker._base_path)
    (when (and prompt (not= prompt ""))
      (if picker._base_path
        (vim.list_extend cmd ["--" picker._base_path])
        (vim.list_extend cmd ["--" prompt]))
      (print (fennel.view cmd))
      cmd)))

(comment
  (normalize-opts {})
  (build-find-command find-command {}))

(fn current-file
  []
  (vim.fn.expand "%:p"))
            
(fn emacs-find-files
  [opts]
  ;; - [x] Start in insert mode
  ;; - [x] ~~Double backspace to go back a directory~~
  ;;       Instead going with ctrl-backspace
  ;; - [ ] TAB Should autocomplete (maybe go through vim-cmp for paths?)
  (let [opts (normalize-opts opts)
        find-command (build-find-command find-command opts)
        finder (finders.new_job #(prompt->find-command find-command $)
                                opts.entry_maker 
                                opts.max_results 
                                opts.cwd)
        sorter (sorters.empty opts)]
    (-> (pickers.new 
          opts
          {:prompt_title "Find Files"
           :__locations_input true
           :default_text (current-file)
           :finder finder
           :previewer (conf.grep_previewer opts)
           :sorter sorter})
        (: :find))))
      
    
(comment
  (telescope.find_files {:initial_mode :insert})
  vim.api.nvim_replace_termcodes
  (find-files {:initial_mode :insert})


  (vim.keymap.set :n :<Leader>ff #(emacs-find-files {:hidden true :no_ignore true})
                  {:desc "Find file"})

  (current-file)
  (-> (current-file)
      (vim.fs.dirname))
  (vim.fn.executable "live_grep")
  
  nil)
    
emacs-find-files
