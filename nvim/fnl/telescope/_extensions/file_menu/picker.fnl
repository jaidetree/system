(local make_entry (require :telescope.make_entry))
(local pickers (require :telescope.pickers))
(local sorters (require :telescope.sorters))
(local finders (require :telescope.finders))
(local actions (require :telescope.actions))
(local {:values conf} (require :telescope.config))
(local {: merge} (require :j.nvim.functions))
(local fm-config (require :telescope._extensions.file_menu.config))

(fn attach-mappings
  [opts]
  (let [attach-mappings opts.attach_mappings]
    (set opts.attach_mappings
         (fn [prompt-bufnr map]
           (each [mode actions (pairs opts.mappings)]
             (each [key action (pairs actions)]
               (map mode key action)))

           (if attach-mappings
             (do
               (attach-mappings prompt-bufnr map))
             ;; Use default keymaps too
             true)))
    opts))

(fn file-menu
  [opts]
  (let [opts (->> opts
                  (merge fm-config.values)
                  (attach-mappings))
        finder (finders.new_table
                 {:results [{:command :tabe
                             :key     :t
                             :title   "Open file in new tab"}
                            {:command :edit
                             :key     :e
                             :title   "Open file in current window"}
                            {:command :vsplit
                             :key     :vsr
                             :title   "Open in vertical-split to the right"}
                            {:command :vsplit
                             :key     :vsl
                             :dir     :left
                             :title   "Open in vertical-split to the left"}
                            {:command :split
                             :key     :st
                             :title   "Open in horizontal-split below"}
                            {:command :split
                             :key     :sa
                             :dir     :above
                             :title   "Open in horizontal-split above"}]
                  :entry_maker (or opts.entry_maker
                                   (fn [line]
                                     (let [{: command : title : key : dir} line]
                                      {:value   opts.filepath
                                       :command command
                                       :display title
                                       :ordinal title
                                       :dir     dir})))})
        sorter (conf.generic_sorter opts)]
    (-> (pickers.new
          opts
          {:prompt_title (.. "Open " opts.filepath "...")
           :finder finder
           :sorter sorter
           :previewer (conf.file_previewer opts)
           :mode :insert})
        (: :find))))


(comment
  (file-menu {:filepath "/Users/j/.config/nix/home/vim.nix"})
  vim.o.splitright
  vim.o.splitbelow
  nil)

file-menu
