(local utils (require :telescope.utils))
(local {: transform_mod} (require :telescope.actions.mt))
(local actions (require :telescope.actions))
(local sa (require :telescope.actions.state))

(fn append-to-history
  [prompt-bufnr]
  (let [history (sa.get_current_history)]
    (history:append (sa.get_current_line) (sa.get_current_picker prompt-bufnr))))

(local custom-actions {})

(fn select-action
  [f]
  (fn select-action
    [prompt-bufnr cmd]
    (let [selection (sa.get_selected_entry)]
      (if (not selection)
        (utils.__warn_no_selection "file_menu")
        (f selection prompt-bufnr cmd)))))

(fn swap-dir
  [option-key value f]
  (let [original (. vim.o option-key)]
    (tset vim.o option-key value)
    (f)
    (tset vim.o option-key original)))

(set custom-actions.open-file
  {:pre append-to-history
   :action (select-action
             (fn open-file-action
               [selection prompt-bufnr cmd]
               (actions.close prompt-bufnr)
               (let [command selection.command
                     ex-command (.. command " " selection.value)]
                 (case [command selection.dir]
                   [:vsplit :left] (swap-dir :splitright false
                                             #(vim.cmd ex-command))
                   [:split :above] (swap-dir :splitbelow false
                                             #(vim.cmd ex-command))
                   _               (vim.cmd ex-command)))))})



(local fm-actions (transform_mod custom-actions))

fm-actions
