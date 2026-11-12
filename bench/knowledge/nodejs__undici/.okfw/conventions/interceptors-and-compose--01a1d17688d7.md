---
id: "01a1d176-88d7-7c17-befe-ef8cd83481ce"
title: "Interceptors and compose"
type: "Guideline"
tags:
  - "architecture"
  - "interceptors"
created: "2026-11-12T14:32:48-06:00"
timestamp: "2026-11-12T14:32:48-06:00"
description: "How undici interceptors are shaped and composed, and the rules a custom or built-in interceptor must follow when wrapping a handler."
x:
  paths: ["lib/interceptor/**/*.js", "lib/handler/**/*.js", "lib/dispatcher/dispatcher.js", "types/interceptors.d.ts"]
  source: ["docs/docs/api/Interceptors.md", "docs/docs/api/Dispatcher.md"]
---

# Interceptors and compose

## Shape

An interceptor is a function that takes a `dispatch` function and returns another dispatch-like function with the same `(options, handler)` signature. `dispatcher.compose(interceptors)` returns a **new** dispatcher that applies the interceptors over the current dispatcher's `dispatch()`. `compose()` can be called repeatedly to chain.

Built-in interceptors live in `interceptors`: `dump`, `retry`, `redirect`, `decompress`, `responseError`, `dns`, `cache`, `deduplicate`. Several of them pair with handler classes (for example `RedirectHandler`, `RetryHandler`).

## Ordering

The two pages describe ordering from different angles, so reviewers should read both carefully:

- `Dispatcher.md`: "The order of the interceptors matters: the last interceptor in the chain is the first to be called" (`compose([i1, i2, i3])` flows request -> i3 -> i2 -> i1 -> dispatch).
- `Interceptors.md`, "Composing multiple interceptors": "The first interceptor in the array wraps the outermost layer", with the example `dns, retry, redirect, decompress, responseError` described as running in that order.

Either way, the docs make ordering significant, so a change that reorders interceptors in a composed chain changes behavior. `Dispatcher.md` also warns: "Forking the chain of interceptors can lead to unexpected results."

## Wrapping handlers

From "Custom interceptors": "When an interceptor wraps the handler, forward the callbacks that it does not handle itself." The documented pattern spreads the original handler (`{ ...handler, onResponseStart(...) { ...; return handler.onResponseStart?.(...) } }`) and calls the downstream callback with optional chaining, passing all arguments through, including `controller`. Wrappers use the controller-based callback names (`onRequestStart`, `onResponseStart`, `onResponseData`, `onResponseEnd`, `onResponseError`); the legacy names are the old API (see the "Dispatcher and handler contract" concept). A wrapped `onResponseError` still must not throw.

## Avoiding double work

The redirect example in `Dispatcher.md` shows that an interceptor which takes over a concern should stop the inner dispatcher from also doing it: it creates a `RedirectHandler` and then dispatches with `maxRedirections: 0` "to stop the sub-dispatcher from also redirecting".

## Examples and resource handling

Interceptor examples consume the body (`await body.dump()`) and close the dispatcher (`await dispatcher.close()`), consistent with the project's body-consumption rule.
