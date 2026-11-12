---
id: "01a1d175-9f96-75fb-baf2-04dcadfe636c"
title: "Encapsulation and Plugin Scope"
type: "Guideline"
tags:
  - "fastify"
  - "plugins"
  - "encapsulation"
  - "architecture"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "How register() creates encapsulated child contexts, when fastify-plugin is the right way to break encapsulation, and the plugin rules a reviewer should check."
x:
  paths: ["fastify.js", "lib/plugin-override.js", "lib/plugin-utils.js", "lib/context.js", "lib/hooks.js", "types/plugin.d.ts", "types/register.d.ts", "types/instance.d.ts"]
  source: ["docs/Reference/Encapsulation.md", "docs/Reference/Plugins.md", "docs/Reference/Hooks.md", "docs/Reference/Warnings.md", "docs/Reference/Principles.md"]
---

# Encapsulation and Plugin Scope

Fastify's central architectural idea is the **encapsulation context**. It decides which decorators, hooks, and plugins are visible to which routes.

## The model

- "Everything in Fastify is a plugin except for the root context."
- `register` "always creates a new Fastify scope". Changes made inside it (decorators, hooks, error handlers, child plugins) affect only that context and its descendants, never its ancestors or siblings. The docs call the result a directed acyclic graph that avoids cross-dependency issues.
- Except for `onClose`, all hooks are encapsulated. `setErrorHandler` is encapsulated too.
- Inside a hook bound with a regular `function`, `this` is the Fastify instance of the context where the route was registered.

## Breaking encapsulation deliberately

When a plugin only extends the server (for example with `decorate`) and its additions must be visible to the parent, it must not create a new scope:

- Wrapping with `fastify-plugin` is the recommended way. It also lets the plugin declare the Fastify version range it supports.
- The hidden `Symbol.for('skip-override')` property also works but "is not recommended": future API changes become the author's responsibility, while `fastify-plugin` ensures backward compatibility.
- A plugin wrapped in `fastify-plugin` ignores the Fastify-specific register options (`prefix`, `logLevel`, and similar), and `onRegister` is not called for it.

## Plugin rules worth checking

- A plugin must signal completion either by returning a Promise (an `async` function) or by calling `done` in callback style, not both. Mixing the two styles in one plugin is listed as warning `FSTWRN002` and as error `FST_ERR_PLUGIN_INVALID_ASYNC_HANDLER`.
- Plugin options should be namespaced to avoid collisions with Fastify's own options.
- Plugin errors are handled through avvio; handle them in the next `after` or `ready`, otherwise they surface in the `listen` callback.
- After `await register(...)` the plugin is finalized; later mutations do not reach the parent.

## Why it matters

Principle 6, "if something could be a plugin, it likely should be", means new behaviour is expected to arrive as a plugin or hook-based extension rather than as a special case in core, and it must respect these scope rules.
