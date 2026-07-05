(local actions (require :telescope.actions))
(local eff-actions (require :telescope._extensions.emacs_find_files.actions))


(fn defaults
  []
  {:mappings {:i {:<BS> eff-actions.back-dir
                  :<TAB> actions.move_selection_better
                  :<S-TAB> actions.move_selection_worse
                  :<CR>    eff-actions.autocomplete}}})

(local config {:values (defaults)})

config
