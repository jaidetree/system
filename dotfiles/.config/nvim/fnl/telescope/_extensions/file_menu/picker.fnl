(local make_entry (require :telescope.make_entry))
(local pickers (require :telescope.pickers))
(local sorters (require :telescope.sorters))
(local finders (require :telescope.finders))
(local actions (require :telescope.actions))
(local {:values conf} (require :telescope.config))
(local {: merge} (require :j.nvim.functions))
(local fm-config (require :telescope._extensions.file_menu.config))
(local fm-make-entry (require :telescope._extensions.file_menu.make_entry))

(local entries
 [{:command  :edit
   :title    "Open file in current window"
   :shortcut :spc}
  {:command  :tabe
   :title    "Open file in new tab"
   :shortcut :t}
  {:command  :vsplit
   :title    "Open in vertical-split to the right"
   :shortcut :/}
  {:command  :vsplit
   :dir      :left
   :title    "Open in vertical-split to the left"
   :shortcut :v}
  {:command  :split
   :title    "Open in horizontal-split below"
   :shortcut :-}
  {:command  :split
   :dir      :above
   :title    "Open in horizontal-split above"
   :shortcut :s}])

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
                 {:results entries
                  :entry_maker (or opts.entry_maker
                                   (fm-make-entry.gen-from-file-actions opts))})
        sorter (conf.generic_sorter opts)]
    (-> (pickers.new
          opts
          {:prompt_title (.. "Open " opts.filepath "...")
           :finder finder
           :sorter sorter
           :previewer (conf.file_previewer opts)
           :initial_mode :normal})
        (: :find))))


(comment
  (file-menu {:filepath "/Users/j/.config/nix/home/vim.nix"})
  vim.o.splitright
  vim.o.splitbelow
  nil)

file-menu
