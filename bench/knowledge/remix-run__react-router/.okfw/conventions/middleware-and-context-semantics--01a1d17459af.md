---
id: "01a1d174-59af-75a1-b971-ea3a6de3e3f9"
title: "Middleware and Context Semantics"
type: "Guideline"
tags:
  - "middleware"
  - "context"
  - "data-strategy"
  - "server"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "Middleware uses a type-safe context API, runs inside the default dataStrategy on the client and once per request on the server, and is data-focused rather than an event system."
x:
  paths: ["packages/react-router/lib/router/**", "packages/react-router/lib/server-runtime/**", "packages/react-router/lib/types/**", "playground/middleware/**"]
  source: ["decisions/0014-context-middleware.md", "docs/upgrading/future.md"]
---

# Middleware and Context Semantics

The Middleware + Context decision sets the design rules for middleware and the `context` object passed to loaders, actions and middleware.

## Type-safe context replaces `AppLoadContext`

- Under the middleware flag (`future.v8_middleware`), the declaration-merged `AppLoadContext` is replaced by a `createContext`-style API: values are read and written with `context.get(key)` and `context.set(key, value)`. Server `getLoadContext` returns a `Map` of context keys to values.
- Client and server get the same context API. Server context is scoped to a request and cleaned up after it; on the client a new context object is created per navigation or fetch to match that behavior.

## Middleware shape

- Routes export an array (`middleware`, and `clientMiddleware` for the client) that runs top-down before handlers. Each function may call `next()` to run handlers and then change the result bottom-up. If a middleware does not call `next`, it is called for it and the response is passed up.
- On the server, `next()` must run the handlers *and* produce the final `Response` (HTML document or data response). On the client there is no single response, so `next` runs handlers and returns nothing.

## Where it runs

- Client middleware is implemented inside the default `dataStrategy`. A user who supplies a custom `dataStrategy` controls the whole data flow, and the router does not run its own middleware first. A `defaultMiddleware` style utility is the intended way to keep middleware while customizing handler execution.
- Because client middleware runs within `dataStrategy`, on a client submission it runs once for the action and again for the revalidating loaders. This is required, because which loaders run depends on the action result via `shouldRevalidate`.
- Server middleware cannot live in `dataStrategy`: a document POST needs both action and loader results to render one HTML response, so it runs once per request.

## Not an event system

The decision says middleware "is data-focused, not an event system". It may run once for actions and once for loaders, runs independently for navigation and fetcher loaders, may run many times on revalidation, and may not run for revalidation opt-outs. Request-method-specific logic in middleware behaves differently for document and data requests and is discouraged.
