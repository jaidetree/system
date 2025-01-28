(local fm-actions (require :telescope._extensions.file_menu.actions))

(fn defaults
  []
  {:mappings {:i {:<CR> fm-actions.open-file}
              :n {:<Space> fm-actions.edit
                  :t       fm-actions.tab
                  :/       fm-actions.vsplit-right
                  :v       fm-actions.vsplit-left
                  :-       fm-actions.split-below
                  :s       fm-actions.split-above}}})

(local config {:values (defaults)})

config
