---
status: accepted
---

# Use rass as the LSP multiplexer for Tailwind, when Tailwind needs to run alongside another server

Eglot manages exactly one language server per buffer (confirmed in the Eglot source Doom's build uses, and in upstream issue #1429, where the maintainer states multi-server-per-buffer is a deliberate non-goal — "use an external multiplexer"). Getting Tailwind CSS completion in JSX/TSX or ClojureScript buffers therefore means either replacing the primary server (typescript-language-server, clojure-lsp) outright, or fronting both servers with a multiplexer that presents as one server to Eglot.

We considered building a custom multiplexer (evaluated as Python or Elixir) before finding `rass` (rassumfrassum, github.com/joaotavora/rassumfrassum) — a multiplexer built by Eglot's own maintainer, already listed as the default first-choice server for python-mode and TS modes in Eglot's own `eglot-server-programs`, just not installed. It supports exactly this shape: spawn N backend servers, merge their responses, and inject per-backend `initializationOptions` via a `rass.<backend-regex>` key (needed for Tailwind's `includeLanguages` mapping in non-standard buffers like `.cljs`).

Decision: adopt rass rather than build custom, for any buffer where Tailwind needs to coexist with another LSP server. It's a young project (no documented crash-recovery behavior, "no warranty" per its own README) but avoids re-solving a problem its adoption already solves, in a build where it's already the preferred default.

Where backend combos aren't in conflict with anything else (e.g. plain `.html`/`web-mode`, where Tailwind is the only server), skip rass entirely and register the server directly — the multiplexer only earns its keep when there's something to multiplex.

Not yet implemented for any buffer as of this ADR (2026-09-20) — only plain HTML/web-mode Tailwind support (no multiplexing needed) was in scope when this was written. Revisit this ADR's assumptions if rass has aged significantly by the time JSX/TSX or CLJS Tailwind support is actually built.
