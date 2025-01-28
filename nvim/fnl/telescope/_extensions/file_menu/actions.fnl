(local utils (require :telescope.utils))
(local {: transform_mod} (require :telescope.actions.mt))
(local actions (require :telescope.actions))
(local sa (require :telescope.actions.state))

(fn append-to-history
  [prompt-bufnr]
  (let [history (sa.get_current_history)]
    (history:append (sa.get_current_line) (sa.get_current_picker prompt-bufnr))))

(local custom-actions {})

(fn with-selection
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

(fn open-file
  [{: cmd : dir : filepath : bufnr}]
  (let [ex-cmd (.. cmd " " filepath)]
    (actions.close bufnr)
    (case [cmd dir]
       [:vsplit :left] (swap-dir :splitright false #(vim.cmd ex-cmd))
       [:split :above] (swap-dir :splitbelow false
                                 #(vim.cmd ex-cmd))
       _               (vim.cmd ex-cmd))))

(set custom-actions.open-file
  {:pre append-to-history
   :action (with-selection
             (fn open-file-action
               [selection prompt-bufnr _cmd]
               (open-file
                 {:cmd selection.command
                  :filepath selection.value
                  :dir selection.dir
                  :bufnr prompt-bufnr})))})



(set custom-actions.edit
     {:pre append-to-history
      :action (with-selection
                (fn [selection prompt-bufnr _cmd]
                  (open-file
                    {:cmd :edit
                     :filepath selection.value
                     :bufnr prompt-bufnr})))})

(set custom-actions.tab
     {:pre append-to-history
      :action (with-selection
                (fn [selection prompt-bufnr _cmd]
                  (open-file
                    {:cmd :tabe
                     :filepath selection.value
                     :bufnr prompt-bufnr})))})

(set custom-actions.vsplit-left
     {:pre append-to-history
      :action (with-selection
                (fn [selection prompt-bufnr _cmd]
                  (open-file
                    {:cmd :vsplit
                     :dir :left
                     :filepath selection.value
                     :bufnr prompt-bufnr})))})

(set custom-actions.vsplit-right
     {:pre append-to-history
      :action (with-selection
                (fn [selection prompt-bufnr _cmd]
                  (open-file
                    {:cmd :vsplit
                     :filepath selection.value
                     :bufnr prompt-bufnr})))})

(set custom-actions.split-above
     {:pre append-to-history
      :action (with-selection
                (fn [selection prompt-bufnr _cmd]
                  (open-file
                    {:cmd :split
                     :dir :above
                     :filepath selection.value
                     :bufnr prompt-bufnr})))})

(set custom-actions.split-below
     {:pre append-to-history
      :action (with-selection
                (fn [selection prompt-bufnr _cmd]
                  (open-file
                    {:cmd :split
                     :filepath selection.value
                     :bufnr prompt-bufnr})))})



(local fm-actions (transform_mod custom-actions))

fm-actions
