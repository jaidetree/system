# Doom Emacs config

Private `$DOOMDIR` (see `init.el` for enabled modules).

## The one command

After changing `packages.el` (or `init.el`), run:

```
~/.config/emacs/bin/doom sync
```

then restart Emacs. Changes to `config.el` alone need neither.

## Notable packages

- **evil-lisp-state** — my fork `jaidetree/evil-lisp-state`, vendored at
  `lisp/evil-lisp-state/` and built from that local tree by straight.
  Provides a Spacemacs-style evil lisp state for structural sexp editing,
  bound under `SPC k` in lisp major modes; any `SPC k` command enters the
  state, `SPC k .` toggles it explicitly, and ESC leaves it. The Doom
  compatibility changes (backend-aware undo/redo instead of hard-coded
  undo-tree; the `.` toggle reachable from normal state) are made at the
  fork's source level in `lisp/evil-lisp-state/evil-lisp-state.el`; the
  major-mode list and `SPC k` leader are set in
  `lisp/evil-lisp-state-setup.el` via `config.el`.

If `doom sync` fails, its output names the failing recipe or file; fix that
and rerun the same command.

## Integration check

The evil-lisp-state setup is asserted by `evil-lisp-state-test.el`, which
loads the exact integration code `config.el` runs and checks every key
binding against the installed package:

```
emacs -Q --batch -l ~/.config/doom/evil-lisp-state-test.el
```

(Or `/Applications/Emacs.app/Contents/MacOS/Emacs` in place of `emacs`.)
It prints `evil-lisp-state OK` and exits 0 when the bindings are live.
