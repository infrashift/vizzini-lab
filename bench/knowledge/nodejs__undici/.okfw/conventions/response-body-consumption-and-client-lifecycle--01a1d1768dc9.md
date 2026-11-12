---
id: "01a1d176-8dc9-70dc-9f88-6c33592c26fe"
title: "Response body consumption and client lifecycle"
type: "Guideline"
tags:
  - "resources"
  - "api"
  - "lifecycle"
created: "2026-11-12T14:32:50-06:00"
timestamp: "2026-11-12T14:32:50-06:00"
description: "undici's rules for consuming or cancelling every response body and for how Client close and destroy move through the client lifecycle."
x:
  paths: ["lib/api/**/*.js", "lib/dispatcher/client.js", "lib/dispatcher/client-h1.js", "lib/dispatcher/client-h2.js", "lib/dispatcher/pool-base.js", "lib/web/fetch/body.js", "lib/web/fetch/response.js"]
  source: ["README.md", "docs/docs/api/Dispatcher.md", "docs/docs/api/api-lifecycle.md"]
---

# Response body consumption and client lifecycle

## Bodies must be consumed or destroyed

`Dispatcher.md` (request): "All response bodies must always be fully consumed or destroyed." The README calls consumption "_mandatory_ for `request`" and shows `await body.dump()` as the fix for code that only reads headers. For `fetch`, the README says "it is important to always either consume or cancel the response body anyway", because Node's garbage collection is less aggressive than a browser's. Leaving connection release to the GC "can lead to excessive connection usage, reduced performance (due to less connection re-use), and even stalls or deadlocks when running out of connections." A `HEAD` request avoids the need when only headers are wanted.

When a body is read conditionally, the other branch must still consume it, for example `if (statusCode === 200) return await body.arrayBuffer(); await body.dump()`.

## Body semantics

- A body can only be consumed once. A second mixin call (e.g. `text()` after `json()`) throws `TypeError` (the README: `TypeError: unusable`, returned through the Promise rejection).
- `dump({ limit })` discards up to `limit` bytes (default `131072`) without destroying the socket.
- The `request` body is always a `Readable`, even when empty; `json()` on an empty body throws. Callers should check for non-`204` status and a JSON `content-type` first.
- `undici.request`'s body does not implement `.formData()`.
- A request can be aborted with an `AbortSignal`, an `EventEmitter` emitting `'abort'`, or by destroying the response body.

## Pipelining and retries

Non-idempotent requests are not pipelined. Idempotent requests are retried automatically after an indirect failure caused by the request at the head of the pipeline, but not when they have a stream request body. Aborting any pipelined request aborts all running requests in that pipeline.

## Client lifecycle

`api-lifecycle.md` models `Client` as states **idle**, **pending**, **processing** (sub-states **running**, **busy**, **closing**) and **destroyed**, and notes this is a conceptual model, not the literal implementation.

- No socket is opened until a request is dispatched.
- `close()` is graceful: with queued requests the client enters **processing.closing**, finishes them, accepts no new ones, then moves to **destroyed** without error.
- `destroy()` moves to **destroyed** immediately and aborts queued requests.
- **busy** is entered only while a `stream.Readable` request body needs draining; no other requests are processed meanwhile.
- **destroyed** is final; further calls reject or fail with `ClientDestroyedError`.
