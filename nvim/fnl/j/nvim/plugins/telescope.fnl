(local ts (require :telescope))
(local builtins (require :telescope.builtin))
(local actions (require :telescope.actions))
(local sa (require :telescope.actions.state))
(local fba (. ts :extensions :file_browser :actions))
(local themes (require :telescope.themes))
(local eff-actions (require :telescope._extensions.emacs_find_files.actions))
(local {: merge } (require :j.nvim.functions))
(local {: transform_mod} (require :telescope.actions.mt))

(fn magic-tab [prmpt-bufnr]
  (let [fba (. ts :extensions :file_browser :actions)
        prompt (sa.get_current_line)
        base (+ actions.toggle_selection actions.move_selection_worse)]
    (if (or (= prompt "..") (= prompt "../")) (fba.goto_parent_dir prmpt-bufnr)
        (or (= prompt "~") (= prompt "~/")) (fba.goto_home_dir prmpt-bufnr)
        (base prmpt-bufnr))))

(local mappings
  {:i {:<C-g> actions.close
       :<Esc> {1 actions.close
               :type :action
               :opts {:nowait true}}}
   :n {:<ESC> {1 actions.close
               :type :action
               :opts {:nowait true}}}})

(fn append-to-history
  [prompt-bufnr]
  (let [history (sa.get_current_history)]
    (history:append (sa.get_current_line) (sa.get_current_picker prompt-bufnr))))

(local custom-actions {})

(set custom-actions.file-menu-action
  {:pre append-to-history
   :action (fn file-menu-action
            [prompt-bufnr]
            (let [selection (sa.get_selected_entry)]
              (actions.close prompt-bufnr)
              (ts.extensions.file_menu.file_menu
                {:filepath selection.value})))})

(local act (transform_mod custom-actions))

(comment
  (fennel.view
   (merge mappings
          {:i {:<CR> file-menu-action}})))


(ts.setup {:defaults {:theme :ivy
                      :vimgrep_arguments ["rg"
                                          "--color=never"
                                          "--no-heading"
                                          "--with-filename"
                                          "--line-number"
                                          "--column"
                                          "--smart-case"
                                          "--no-ignore-vcs"]}

           :pickers {:find_files          {:theme    :ivy
                                           :hidden   true
                                           :mappings (merge mappings
                                                            {:i {"<CR>" act.file-menu-action}})}
                     :git_files           {:theme    :ivy
                                           :mappings (merge mappings
                                                            {:i {"<CR>" act.file-menu-action}})}
                     :commands            {:mappings mappings}}

           :extensions {:ui-select        [(themes.get_dropdown {})]
                        :undo             {}

                        :emacs_find_files {:theme    :ivy
                                           :hidden   true
                                           :mappings mappings
                                           :attach_mappings
                                           (fn [prompt-bufnr]
                                             (actions.select_default:replace
                                               (fn []
                                                 (let [selection (sa.get_selected_entry)]
                                                    (print "selection.value" (fennel.view selection.value))
                                                    (ts.extensions.file_menu.file_menu
                                                      {:filepath selection.value})))))}

                        :file_menu        {:mappings mappings}

                        :file_browser     {:theme         :ivy
                                           :grouped       true
                                           :select_buffer true
                                           :hijack_netrw  false
                                           :cwd_to_path   true
                                           :path          "%:p:h"
                                           :mappings      {:i {:^     fba.goto_parent_dir
                                                               "~"    fba.goto_home_dir
                                                               :<Tab> magic-tab
                                                               :<CR>  actions.select_tab
                                                               :<C-o> actions.select_default}}}}})

;; (ts.load_extension :file_browser)
(ts.load_extension :projects)
(ts.load_extension :yank_history)
(ts.load_extension :notify)
(ts.load_extension :ui-select)
(ts.load_extension :undo)
(ts.load_extension :file_menu)
(ts.load_extension :emacs_find_files)

(comment
  (builtins.git_files
    {:mappings {:i {:<CR> act.file-menu-action}}})
  (ts.extensions.emacs_find_files.emacs_find_files
    {:mappings {:i {:<CR> act.file-menu-action}}})
  (ts.extensions.file_menu.file_menu
    {:filepath "/Users/j/.config/nix/home/vim.nix"}))


