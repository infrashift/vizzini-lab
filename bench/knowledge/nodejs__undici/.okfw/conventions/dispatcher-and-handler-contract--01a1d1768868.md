---
id: "01a1d176-8868-7740-aeea-4e0ebfbdccee"
title: "Dispatcher and handler contract"
type: "Guideline"
tags:
  - "architecture"
  - "api"
  - "dispatcher"
created: "2026-11-12T14:32:48-06:00"
timestamp: "2026-11-12T14:32:48-06:00"
description: "The low-level dispatch(options, handler) contract that every concrete dispatcher and handler in undici implements, including the controller-based handler callbacks."
x:
  paths: ["lib/dispatcher/**/*.js", "lib/handler/**/*.js", "types/dispatcher.d.ts", "types/handlers.d.ts", "types/dispatcher1-wrapper.d.ts"]
  source: ["docs/docs/api/Dispatcher.md", "docs/docs/best-practices/migrating-from-v7-to-v8.md", "README.md"]
---

# Dispatcher and handler contract

## Architecture

`Dispatcher` is "the core abstraction used to dispatch HTTP requests". It extends `EventEmitter`; its `dispatch()`, `close()` and `destroy()` throw `not implemented`, and concrete dispatchers (`Client`, `Pool`, `BalancedPool`, `Agent`, and the proxy/retry agents) implement them. The higher-level `request()`, `stream()`, `pipeline()`, `connect()` and `upgrade()` are built on `dispatch()`. Requests are not guaranteed to be dispatched in invocation order.

`dispatch()` is "expected to evolve through semver-major versions and is less stable than the higher-level methods". Changes to its shape are breaking changes.

## Handler callbacks (current API)

The handler passed to `dispatch()` uses controller-first callbacks:

- `onRequestStart(controller, context)`: before the request goes on the socket; **may be invoked multiple times when the request is retried**.
- `onRequestUpgrade(controller, statusCode, headers, socket)`: required when `upgrade` is set or the method is `CONNECT`.
- `onResponseStart(controller, statusCode, headers, statusMessage)`: may run several times for 1xx responses; not used for upgrades.
- `onResponseData(controller, chunk)`, `onResponseEnd(controller, trailers)`.
- `onResponseError(controller, error)`: **must not throw**.
- `onBodySent(chunk)` receives the actual chunk (not counters); `onRequestSent()` fires once the whole body is sent.

The legacy callbacks (`onConnect`, `onHeaders`, `onData`, `onComplete`, `onError`, `onUpgrade`) are the old style that the migration guide tells custom dispatchers and interceptors to replace.

## Backpressure and abort go through the controller

The `DispatchController` exposes `aborted`, `paused`, `reason`, `rawHeaders`, `rawTrailers`, `abort(reason)`, `pause()` and `resume()`. The docs say: "Call `controller.pause()` and `controller.resume()` to apply backpressure rather than returning `false` from a handler." Raw header arrays come from `controller.rawHeaders`/`rawTrailers`, not from callback arguments.

## Return value and drain

`dispatch()` returns `false` when the dispatcher is busy; further calls make no progress until `'drain'` is emitted. `destroy()` aborts pending and running requests asynchronously, so they may still make some progress first; `close()` waits for enqueued requests.

## Legacy consumers

Node.js built-in `fetch` still uses the legacy (v1) handler contract. `setGlobalDispatcher()` stores the dispatcher under `Symbol.for('undici.globalDispatcher.2')` and mirrors a `Dispatcher1Wrapper` under `Symbol.for('undici.globalDispatcher.1')`. Code should use the public `setGlobalDispatcher()`/`getGlobalDispatcher()` rather than those symbols, and wrap dispatchers with `Dispatcher1Wrapper` when they must serve v1 consumers.
