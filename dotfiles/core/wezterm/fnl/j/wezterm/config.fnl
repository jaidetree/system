(local wezterm (require :wezterm))

(local config (wezterm.config_builder))

(local configdir wezterm.config_dir)

(wezterm.add_to_config_reload_watch_list (.. configdir "/fnl/j/wezterm/config.fnl"))

;; (tset config :color_scheme :Dracula)
(tset config :color_scheme "Catppuccin Mocha")

(tset config :default_prog [_G.config-paths.fish "-l"])
(tset config :font (wezterm.font "0xProto Nerd Font" {:weight :Regular}))
(tset config :font_size 12)
(tset config :front_end "WebGpu")
(tset config :webgpu_power_preference "HighPerformance")

(tset config :window_decorations "RESIZE")

config
