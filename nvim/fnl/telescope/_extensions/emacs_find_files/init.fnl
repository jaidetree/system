(local telescope (require :telescope))
(local eff-actions (require :telescope._extensions.emacs_find_files.actions))
(local eff-config (require :telescope._extensions.emacs_find_files.config))
(local eff-picker (require :telescope._extensions.emacs_find_files.picker))

(fn copy-defaults
  []
  (vim.deepcopy eff-config.values))

(fn emacs-find-files
  [opts]
  (let [opts (or opts {})
        defaults (copy-defaults)]
    (when eff-config.values.mappings
      (set defaults.attach_mappings
           (fn [prompt-bufnr map]
             ;; Attach mappings from base config for this module
             (when eff-config.values.attach_mappings
               (eff-config.values.attach_mappings prompt-bufnr map))
             
             ;; Copy pre-defined mappings defined from telescope.setup
             (each [mode tbl (pairs eff-config.values.mappings)]
               (each [key action (pairs tbl)]
                 (map mode key action)))
             
             ;; Extend default mappings
             true)))
    (when opts.attach_mappings
      (let [opts-attach opts.attach_mappings]
        (set opts.attach_mappings
             (fn [prompt-bufnr map]
               (defaults.attach_mappings prompt-bufnr map)
               (opts-attach prompt-bufnr map)))))
    
    (let [popts (vim.tbl_deep_extend  :force defaults opts)]
      (eff-picker popts))))
    

(telescope.register_extension 
  {:setup eff-config.setup
   :exports {:emacs_find_files emacs-find-files}})

