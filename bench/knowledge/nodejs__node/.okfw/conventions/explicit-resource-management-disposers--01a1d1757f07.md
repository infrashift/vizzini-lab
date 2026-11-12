---
id: "01a1d175-7f07-704d-95c3-653811e63039"
title: "Explicit Resource Management Disposers"
type: "Guideline"
tags:
  - "javascript"
  - "resource-management"
  - "dispose"
  - "api"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Rules for implementing and using Symbol.dispose and Symbol.asyncDispose on core objects."
x:
  paths: ["lib/**/*.js"]
  source: ["doc/contributing/erm-guidelines.md"]
---

# Explicit Resource Management Disposers

Core objects that support `using` / `await using` must follow the explicit resource management guidelines.

**Implementing disposers**

1. Disposers must be idempotent: repeated calls have no extra side effects.
2. Assume a pending exception. If the object was not explicitly closed, dispose as if an error occurred (for example, call `abort()` rather than `close()` when both exist).
3. Avoid throwing inside disposers, because a throw during another pending exception produces a `SuppressedError` that masks both.
4. Expose a named disposal method (such as `close()`), and have `Symbol.dispose` / `Symbol.asyncDispose` call it idempotently.
5. Prefer synchronous `Symbol.dispose` over `Symbol.asyncDispose` where possible. Async disposal delays exception handling.
6. A `Symbol.asyncDispose` method must be `async` and must `await` at least one asynchronous disposal task; otherwise it is a sync disposer in disguise and should be `Symbol.dispose`.
7. All work must be complete when the disposer returns: do not call callback-style APIs unless they are promisified and awaited, and await every Promise created inside the disposer.
8. Avoid defining both `Symbol.dispose` and `Symbol.asyncDispose` on one object unless the resource already has both sync and async close paths.

**Return values and debuggability**

- `Symbol.dispose` returns `undefined`; `Symbol.asyncDispose` returns a Promise resolving to `undefined`.
- Do not alias the symbol method directly to the named function (`[Symbol.dispose]: dispose`). Write `[Symbol.dispose]() { this.dispose(); }` so stack traces show whether disposal came from `using`.

**Retrofitting existing APIs**

- Do not make return values polymorphic depending on an option. If an API already returns an object, it can be made disposable. If it returns something that cannot be (such as a string), add a new API variant instead.
- Changing an existing return type is likely a breaking change, and deprecating the old API in favor of a new one is never a decision to take lightly.
- Document that an object is disposable and how to dispose of it.

**Using disposables in core**

- Never apply `using` to an object you do not own, because it will be disposed unconditionally when the block exits.
- Where success and error disposal differ, explicitly dispose on successful paths, including early returns.
