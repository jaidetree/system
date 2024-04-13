(local utils (require :telescope.utils))
(local make_entry (require :telescope.make_entry))
(local pickers (require :telescope.pickers))
(local finders (require :telescope.finders))
(local {:values conf} (require :telescope.config))

(local find-command ["rg" "--files" "--color" "never"])
(local command "rg")

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
    (when opts.search_file
      (append-arg "-g")
      (append-arg (.. "*" opts.search_file "*")))
    (when opts.search_dirs
      (vim.list_extend command opts.search-dirs))
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
    (set tbl.entry_maker (or tbl.entry_maker (make_entry.gen_from_file tbl)))
    tbl))

(comment
  (normalize-opts {}))
            
(fn find-files
  [opts]
  ;; @TODO Get the filter input text
  ;; @TODO Get the opts.cwd or current directory of the buffer
  ;; @TODO Update the find command to search in 
  ;; @TODO Filter the results using the input text
  (let [opts (normalize-opts opts)
        find-command (build-find-command find-command opts)
        finder (finders.new_oneshot_job find-command opts)
        sorter (conf.file_sorter opts)]
    (-> (pickers.new 
          opts
          {:prompt_title "Find Files"
           :__locations_input true
           :finder finder
           :previewer (conf.grep_previewer opts)
           :sorter    sorter})
        (: :find))))
         
      
    
(find-files {})
    
        
    
    
    
