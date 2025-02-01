(local entry-display (require :telescope.pickers.entry_display))
(local make-entry (require :telescope.make_entry))

(fn gen-from-file-actions
  [opts]
  (let [displayer (entry-display.create {:separator "▏"
                                         :items [{:width 8}
                                                 {:width 8}
                                                 {:remaining true}]})
        make-display (fn [entry]
                       (displayer
                         [entry.command
                          entry.shortcut
                          entry.title]))]
    (fn [entry]
      (make-entry.set_default_entry_mt
        {:command  entry.command
         :dir      entry.dir
         :display  make-display
         :ordinal  entry.title
         :shortcut entry.shortcut
         :title    entry.title
         :value    opts.filepath}

        opts))))



{: gen-from-file-actions}
