# dotfiles

Personal system configuration: Nix-managed macOS environment, Doom Emacs config, and the tooling that glues them together.

## Language

**LSP multiplexer**:
A process that presents to Eglot as a single managed language server for a buffer, but internally spawns and coordinates several real backend servers on the buffer's behalf, merging their responses (e.g. completion, diagnostics) into what Eglot sees as one server's output. `rass` (rassumfrassum) is the multiplexer adopted in this repo.
_Avoid_: proxy, aggregator (as a standalone term — "multiplexer" is the chosen name; "aggregator" only describes one *behavior* a multiplexer performs, namely fan-out-and-merge, as opposed to single-owner routing)

**Backend server**:
One of the real language servers an LSP multiplexer manages on a buffer's behalf (e.g. `typescript-language-server`, `tailwindcss-language-server`, `clojure-lsp`). Distinct from the multiplexer itself, which is what Eglot actually launches and talks to.
_Avoid_: upstream server, child server
