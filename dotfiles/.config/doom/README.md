# Doom Emacs config

Private `$DOOMDIR` (see `init.el` for enabled modules).

## The one command

After changing `packages.el` (or `init.el`), run:

```
~/.config/emacs/bin/doom sync
```

then restart Emacs. Changes to `config.el` alone need neither.

If `doom sync` fails, its output names the failing recipe or file; fix that
and rerun the same command.

## Private modules

- **`modules/editor/lisp-state`** — Spacemacs-style evil lisp state for
  structural sexp editing (my `jaidetree/evil-lisp-state` fork, vendored
  in-module). See its `README.org` for usage and how to run its
  integration test.
