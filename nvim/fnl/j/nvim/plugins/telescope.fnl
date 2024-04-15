(local ts (require :telescope))
(local actions (require :telescope.actions))
(local sa (require :telescope.actions.state))
(local fba (. ts :extensions :file_browser :actions))
(local themes (require :telescope.themes))
(local eff-actions (require :telescope._extensions.emacs_find_files.actions))

(fn magic-tab [prmpt-bufnr]
  (let [fba (. ts :extensions :file_browser :actions)
        prompt (sa.get_current_line)
        base (+ actions.toggle_selection actions.move_selection_worse)]
    (if (or (= prompt "..") (= prompt "../")) (fba.goto_parent_dir prmpt-bufnr)
        (or (= prompt "~") (= prompt "~/")) (fba.goto_home_dir prmpt-bufnr)
        (base prmpt-bufnr))))

(local mappings 
  {:i {:<C-g> actions.close 
       :<Esc> actions.close
       :<C-o> actions.select_default
       :<CR> actions.select_tab}
   :n {:<C-g> actions.close
       :<C-o> actions.select_default
       :<CR> actions.select_tab
       :<ESC> actions.close}})

(ts.setup {:defaults {:theme :ivy}
                                     
           :pickers {:find_files {:theme :ivy 
                                  :no_ignore true
                                  :no_ignore_parent true
                                  :hidden true
                                  :mappings mappings} 
                     :git_files {:theme :ivy
                                 :mappings mappings}}
           :extensions {:ui-select [(themes.get_dropdown {})]
                        :undo         {}
                        :emacs_find_files {:theme :ivy
                                           :mappings {:i {:<C-g> actions.close 
                                                          :<Esc> actions.close
                                                          :<C-o> actions.select_default}
                                                      :n {:<C-g> actions.close
                                                          :<C-o> actions.select_default
                                                          :<ESC> actions.close}}}

                        :file_browser {:theme :ivy
                                       :grouped true
                                       :select_buffer true
                                       :hijack_netrw false
                                       :cwd_to_path true
                                       :path "%:p:h"
                                       :mappings {:i {:^ fba.goto_parent_dir
                                                      "~" fba.goto_home_dir
                                                      :<Tab> magic-tab
                                                      :<CR> actions.select_tab
                                                      :<C-o> actions.select_default}}}}})

(ts.load_extension :file_browser)
(ts.load_extension :projects)
(ts.load_extension :yank_history)
(ts.load_extension :notify)
(ts.load_extension :ui-select)
(ts.load_extension :undo)
(ts.load_extension :emacs_find_files)
