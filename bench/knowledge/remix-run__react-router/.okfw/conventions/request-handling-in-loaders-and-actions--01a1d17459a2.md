---
id: "01a1d174-59a2-7a56-98e8-1a8f21b4c366"
title: "Request Handling in Loaders and Actions"
type: "Guideline"
tags:
  - "server"
  - "request"
  - "fetch-api"
  - "streaming"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "Requests are passed to user code uncloned, loaders get no body, cancellation uses request.signal, and deferred promises must stay trackable by the router."
x:
  paths: ["packages/react-router/lib/server-runtime/**", "packages/react-router/lib/router/router.ts", "packages/react-router/lib/dom/ssr/single-fetch.tsx"]
  source: ["decisions/0002-do-not-clone-request.md", "decisions/0005-remixing-react-router.md", "decisions/0004-streaming-apis.md", "decisions/0003-data-strategy.md"]
---

# Request Handling in Loaders and Actions

Several accepted decisions define how the framework hands requests to user code and handles their results.

## Do not clone requests

Decision 0002: requests used to be cloned so that several loaders or actions could read the body. That made some runtimes buffer the body and goes against the platform rule that a request body is consumed once. The decision:

- "Do not clone requests before they are passed to user-code (actions, handleDocumentRequest, handleDataRequest)".
- Remove the body from the request passed to loaders. Loaders are "GET" / "HEAD" handlers, so "Loaders always receive a null body for the request."

A change that reintroduces cloning, or hands loaders a request with a body, goes against this decision. Users who really need to read a body twice are told to call `.clone()` themselves and accept the tradeoffs.

## Cancellation through `request.signal`

Loaders and actions get no separate `signal` parameter; they use the `Request`'s own `signal`. Interrupted navigations cancel in-flight data requests, so that signal is how user code sees the abort.

## Deferred and streamed data

Decision 0004 describes streaming: a loader returns an object in which some values are `Promise`s, and components render them with `<Await>` inside `<React.Suspense>`. `useAsyncValue` and `useAsyncError` only work inside `<Await>`. If no `errorElement` is given, rejections go up to the nearest route error boundary. The decision warns that raw promises the router does not know about cannot be cancelled when the user navigates away. The router must be able to track in-flight promises so it can cancel them and avoid UI flicker.

## Data strategy responsibilities

Decision 0003 splits loader execution into four steps: match routes, decide which to load (`shouldRevalidate`), call handlers in parallel, decode responses. `dataStrategy` controls "*when* handlers are called, not *how*. RR is in charge of calling them with the right parameters". Each match's `match.resolve` is used to run its handler. If a handler result is a `Response`, the router unwraps it and processes redirects. Any other value is passed through untouched as success or error data.
