(local telescope (require :telescope))
(local eff-actions (require :telescope._extensions.emacs_find_files.actions))
(local emacs-find-files (require :telescope._extensions.emacs_find_files.picker))
(local eff-config (require :telescope._extensions.emacs_find_files.config))
(local themes (require :telescope.themes))
(local {: merge} (require :j.nvim.functions))

(fn theme-opts
  [opts]
  (if opts.theme
    (let [theme-key opts.theme
          method-name (.. "get_" theme-key)
          theme-fn (. themes method-name)]
      (theme-fn opts))
    opts))

(fn setup
  [ext-opts ts-opts]
  (set eff-config.values (merge eff-config.values (theme-opts ext-opts))))

(telescope.register_extension
  {:setup setup
   :exports {:emacs_find_files emacs-find-files}})

