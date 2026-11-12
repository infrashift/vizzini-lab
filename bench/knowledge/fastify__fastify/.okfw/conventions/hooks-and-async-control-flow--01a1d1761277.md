---
id: "01a1d176-1277-7aad-bf1d-64c2ab547bae"
title: "Hooks and Async Control Flow"
type: "Guideline"
tags:
  - "fastify"
  - "hooks"
  - "async"
  - "lifecycle"
  - "reply"
created: "2026-11-12T14:32:18-06:00"
timestamp: "2026-11-12T14:32:18-06:00"
description: "Rules for callback versus async hooks and handlers, early replies, and per-hook contracts that prevent double execution and race conditions."
x:
  paths: ["lib/hooks.js", "lib/route.js", "lib/reply.js", "lib/handle-request.js", "lib/wrap-thenable.js", "lib/promise.js", "types/hooks.d.ts", "types/route.d.ts"]
  source: ["docs/Reference/Hooks.md", "docs/Reference/Routes.md", "docs/Reference/Errors.md", "docs/Reference/Lifecycle.md"]
---

# Hooks and Async Control Flow

Fastify supports both callback-style and `async`/Promise-style hooks and handlers. Most lifecycle bugs come from mixing them, so the docs are strict.

## One style per function

- "The `done` callback is not available when using `async`/`await` or returning a `Promise`." Calling it anyway may cause "duplicate invocation of handlers". An async hook that declares `done` is `FST_ERR_HOOK_INVALID_ASYNC_HANDLER`.
- "It is important to **not mix callbacks and `async`/`Promise`**, otherwise the hook chain will be executed twice."
- For route handlers the docs recommend using "only one style for consistent" error handling, even though both are supported.

## Replying early or outside the promise chain

- A callback hook replies by calling `reply.send()` and not calling `done`.
- In an `async` hook, `reply.send()` must be called before the function returns or the promise resolves, otherwise the request proceeds.
- If `reply.send()` is called outside the promise chain (in `setImmediate`, a timer, or a plugin that sends asynchronously such as `sendFile`), the hook or handler must `return reply` (or `await reply`). Otherwise the request runs on and fails with `FST_ERR_REP_ALREADY_SENT`.
- In an async handler: either return the value, or call `reply.send` and `return reply`. Using both is discarded with a warn log; `undefined` cannot be returned.
- Streaming a response from an `async` hook is discouraged; use a callback hook.

## Per-hook contracts

- `request.body` is always `undefined` in `onRequest` and `preParsing`.
- `preParsing`, if it returns anything, must return a stream; it should set `receivedEncodedLength` on it, and its size is checked against `bodyLimit`.
- `preSerialization` is not called for `string`, `Buffer`, stream, or `null` payloads.
- `onError` is for logging or adding headers only. It is "not intended for changing the error", calling `reply.send` in it throws (`FST_ERR_SEND_INSIDE_ONERR`), and passing an error to its `done` is not supported.
- `onRoute` hooks that add routes must tag them (for example with a symbol in `custom`) or they loop forever.
- `onRequestAbort` cannot send data, and abort detection "is not completely reliable".

## Errors from hooks

Pass an error to `done(err)` or `throw` in an async hook; Fastify closes the request and sends the error. Set a status with `reply.code()` first if needed. See "Error Handling Conventions".
