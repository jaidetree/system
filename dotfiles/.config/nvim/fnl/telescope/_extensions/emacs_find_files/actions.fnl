(local {:transform_mod transform-mod} (require :telescope.actions.mt))
(local core-actions (require :telescope.actions))
(local actions-state (require :telescope.actions.state))

(local actions {})

(fn actions.back-dir
  [prompt-bufnr]
  (let [picker (actions-state.get_current_picker prompt-bufnr)
        prompt (actions-state.get_current_line)
        dirname (if (vim.endswith prompt "/")
                  (-> prompt
                      (vim.fs.dirname)
                      (vim.fs.dirname))
                  (vim.fs.dirname prompt))]
    (if (and picker._time (< (- (vim.loop.now) picker._time) 400))
      (do
        (picker:set_prompt (.. dirname "/"))
        (set picker._time nil)
        nil)
      (do
        (set picker._time (vim.loop.now))
        (vim.api.nvim_feedkeys (vim.api.nvim_replace_termcodes "<C-H>" true false true) "i" false)
        "<BS>"))))

(fn ask-to-confirm
  [prompt default-value yes-values]
  (let [yes-values (or yes-values [:y :yes])
        default-value (or default-value "")
        confirmation (string.lower (vim.fn.input prompt default-value))]
    (if (= (string.len confirmation) 0)
      false
      (do
        (each [_ v (ipairs yes-values)]
          (when (= v confirmation)
            (lua "return v")))
        false))))

(fn actions.autocomplete
  [prompt-bufnr]
  ;; (actions.drop_all prompt-bufnr)
  (let [picker (actions-state.get_current_picker prompt-bufnr)
        base (actions-state.get_current_line)
        entry (actions-state.get_selected_entry)
        path (if (= entry nil) nil (. entry 1))]
    (if
      (= entry nil)
      (do
        (when (ask-to-confirm
                (.. "File " base " does not exist. Would you like to create it? ")
                "y")
          (core-actions.select_default prompt-bufnr)))

      (= picker._last_path path)
      (do
        (set picker._last_path nil)
        (core-actions.select_default prompt-bufnr))

      (do
        (set picker._last_path path)
        (picker:set_prompt path)))
    nil))

(local eff-actions (transform-mod actions))

eff-actions
