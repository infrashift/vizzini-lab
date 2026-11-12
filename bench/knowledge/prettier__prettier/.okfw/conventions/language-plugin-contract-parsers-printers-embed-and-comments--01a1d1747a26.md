---
id: "01a1d174-7a26-7829-a7ef-a74c2aeb1b23"
title: "Language plugin contract: parsers, printers, embed and comments"
type: "Guideline"
tags:
  - "plugins"
  - "api"
  - "comments"
  - "embed"
created: "2026-11-12T14:30:34-06:00"
timestamp: "2026-11-12T14:30:34-06:00"
description: "Built-in languages and external plugins share one plugin contract, and plugins.md defines the required shape and behavior of parsers, printers, embed, visitor keys and comment handling."
x:
  paths: ["src/main/**", "src/language-*/**", "packages/plugin-*/*.js"]
  source: ["docs/plugins.md", "docs/api.md"]
---

# Language plugin contract: parsers, printers, embed and comments

## Shape of a plugin

A plugin exports `languages`, `parsers`, `printers`, `options` and `defaultOptions`. Language definitions **must** include `name` and `parsers`. A parser entry maps a parser name to `parse`, an `astFormat` name and `locStart`/`locEnd`, with optional `hasPragma`, `hasIgnorePragma` and `preprocess`. A printer is keyed by the `astFormat` the parser produces and must provide `print`; everything else is optional. The old custom parser API was removed in favor of this Plugin API.

## Printing pipeline

1. optional AST `preprocess`;
2. optional comment attachment;
3. optional `embed` for embedded languages, called depth-first;
4. recursive printing via `print(path, options, print)`.

`options` is a persistent object that a plugin may mutate to store contextual data. Child nodes are printed through the `print` callback, not by calling the printer directly.

## `embed`

- The recursion is synchronous "for performance reasons"; asynchronous work must happen inside the function that `embed` returns, which receives `textToDoc` to parse and print another language. Returned functions run sequentially before printing.
- Returning `undefined`, or a function that returns `undefined`, throws or rejects, falls back to normal `print` for that node. Set `PRETTIER_DEBUG` to rethrow these errors while debugging.
- With `--embedded-language-formatting=off`, `embed` is not called at all, so printers must still produce correct output through `print` alone.

## `getVisitorKeys`

Comment attachment and embedding traverse the AST. Without visitor keys they walk every own enumerable property, which loops forever on cyclic ASTs and wastes work on non-node data such as location objects. A full visitor-key table should return `[]` for unknown nodes to avoid falling back to `Object.keys()`.

## Comments

If the AST root has a `comments` array, Prettier attaches each comment to a node using `locStart`/`locEnd`, **mutating the AST**, and deletes the root `comments` property. `canAttachComment`, `isBlockComment`, `getCommentChildNodes`, `printComment` and `handleComments` adjust this. The `handleComments` functions (`ownLine`, `endOfLine`, `remaining`) must either attach the comment themselves and return `true`, or return `false` to let Prettier decide. Manual attachment should use `addLeadingComment` / `addTrailingComment` / `addDanglingComment`, which set `leading`, `trailing` and `printed` correctly. `--debug-print-comments` shows how each comment was classified and attached.

## Utilities

`prettier.util` exposes a limited set of helpers (skip functions, `getStringWidth`, `getPreferredQuote`, `makeString`, `isNextLineEmpty` and similar) for plugins.
