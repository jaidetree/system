(local fm-actions (require :telescope._extensions.file_menu.actions))

(fn defaults
  []
  {:mappings {:i {:<CR> fm-actions.open-file}}})

(local config {:values (defaults)})

(print "config" (fennel.view config))

config
