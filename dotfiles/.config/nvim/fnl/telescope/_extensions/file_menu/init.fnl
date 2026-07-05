(local telescope (require :telescope))
(local themes (require :telescope.themes))
(local fm-actions (require :telescope._extensions.file_menu.actions))
(local fm-config (require :telescope._extensions.file_menu.config))
(local file-menu (require :telescope._extensions.file_menu.picker))
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
  (set fm-config.values (merge fm-config.values (theme-opts ext-opts))))

(telescope.register_extension
  {:setup setup
   :exports {:file_menu file-menu}})

