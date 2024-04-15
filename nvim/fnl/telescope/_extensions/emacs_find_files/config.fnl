(local actions (require :telescope.actions))
(local eff-actions (require :telescope._extensions.emacs_find_files.actions))

(local config {})


(local defaults 
  {:mappings {:i {:<BS> eff-actions.back-dir
                  :<TAB> actions.move_selection_better
                  :<S-TAB> actions.move_selection_worse
                  :<CR>    eff-actions.autocomplete}}
   :attach_mappings (fn [_ _]
                      (comment
                        (action-set.select:replace_map
                          {entry-is-dir? eff-actions.open-dir
                           entry-is-nil? eff-actions.create-from-prompt}))
                      true)})

(set config.values defaults)

(fn config.setup
  [opts]
  (let [telescope-config (require :telescope.config)]
    (set config.values.mappings 
         (vim.tbl_deep_extend 
           :force 
           config.values.mappings 
           telescope-config.values.mappings))
    (when opts.attach_mappings
      (let [opts-attach opts.attach_mappings
            default-attach config.values.attach_mappings]
        (set opts.attach_mappings
             (fn [prompt-bufnr map]
               (default-attach prompt-bufnr map)
               (opts-attach prompt-bufnr map)))))
    (set config.values 
         (vim.tbl_deep_extend :force config.values opts))))
                       
                


config
