---
id: "01a1d176-9314-72f1-88da-68f4c6c13f06"
title: "API stability, compatibility and documentation conventions"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "documentation"
created: "2026-11-12T14:32:51-06:00"
timestamp: "2026-11-12T14:32:51-06:00"
description: "How undici marks API stability, which surfaces are public, how cross-version compatibility is kept, and how API docs and types must be kept in sync with code."
x:
  paths: ["docs/docs/**/*.md", "docs/docs/site.json", "docs/docs/type-map.json", "types/**/*.d.ts", "index.js", "lib/global.js", "lib/core/diagnostics.js"]
  source: ["docs/README.md", "types/README.md", "docs/docs/api/Dispatcher.md", "docs/docs/api/DiagnosticsChannel.md", "docs/docs/api/Debug.md", "docs/docs/best-practices/migrating-from-v7-to-v8.md", "README.md", ".github/PULL_REQUEST_TEMPLATE.md"]
---

# API stability, compatibility and documentation conventions

## Stability levels

Each API page carries a Node.js-style stability marker: `2 - Stable` for most classes (`Dispatcher`, `Client`, `Pool`, `Agent`, `Errors`), `1 - Experimental` for some (`DiagnosticsChannel`, `SnapshotAgent`, `Socks5ProxyAgent`, parts of `WebSocket`, `EventSource` and `Fetch`), and `0 - Deprecated` for deprecated items. Pages also carry `<!-- YAML added: ... changes: ... -->` blocks recording when an API was added or changed. Within the stable surface, `dispatch()` is singled out as "expected to evolve through semver-major versions".

## Public versus internal surfaces

- Global dispatcher: use `setGlobalDispatcher()`/`getGlobalDispatcher()`. The `Symbol.for('undici.globalDispatcher.1'/'.2')` slots are internal; the global dispatcher is "shared among compatible undici modules, including undici that is bundled internally with node.js".
- Errors: the `code` string is the cross-version contract (see the "Error classes and codes" concept).
- `fetch` and `FormData` must come from the same implementation; mixing a global `FormData` with `undici.fetch()` (or the reverse) is called out as something to avoid.
- Top-level APIs take a `url` argument; `origin`/`path` belong to the lower-level dispatcher options only.

## Diagnostics and debug output

Diagnostics channels are the "preferred way to observe undici's internal behaviour without patching the library". Every message is a single object whose shape depends on the channel; subscribers run synchronously inside undici and "should be fast and must not throw". The same `request` object is shared across all `undici:request:*` channels for one request. Debug logs use `util.debuglog()` namespaces (`undici`, `fetch`, `websocket`) via `NODE_DEBUG`.

## Documentation must move with the code

The PR template asks contributors to update documentation. The docs site is built with doc-kit:

- Pages are **not** auto-discovered. A new page appears in the sidebar only when added to `docs/docs/site.json`, and order there is significant.
- Types are annotated `{TypeName}`. Each name needs an entry in `docs/docs/type-map.json`; an unmatched annotation renders as plain text, so the map must be kept in sync "when headings are renamed or pages move".

## Types

`types/` holds the TypeScript declarations. They ship in `undici` and are also dual-published as `undici-types` with every release (for consumers such as `@types/node`), so public API changes need matching `.d.ts` changes.

## Runtime support

undici versions align with the Node.js LTS schedule, and each major line states a minimum Node.js version in the README's support table.
