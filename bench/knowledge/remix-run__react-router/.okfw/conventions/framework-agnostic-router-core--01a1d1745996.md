---
id: "01a1d174-5996-7200-99b5-abe5ef256241"
title: "Framework-Agnostic Router Core"
type: "Guideline"
tags:
  - "architecture"
  - "router"
  - "history"
  - "module-boundaries"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "Routing, data loading and navigation logic live in a router core that does not depend on React, with history treated as an internal implementation detail."
x:
  paths: ["packages/react-router/lib/router/**", "packages/react-router/lib/components.tsx", "packages/react-router/lib/hooks.tsx"]
  source: ["decisions/0005-remixing-react-router.md"]
---

# Framework-Agnostic Router Core

The "Remixing React Router" decision records how the data APIs (loaders, actions, fetchers) were brought into React Router. Several of its decisions describe boundaries the router core is meant to keep.

## No UI-library knowledge in the router

The decision moved "the bulk of logic to a framework-agnostic router". The router answers questions like "what route am I on?", "how do I load data for the next route?", and "how do I interrupt ongoing navigations?", and none of these depend on how routes are rendered. The router only needs to know *whether* a route has a component or error boundary, not how to render it. The doc calls this "a strict requirement" for eventually supporting UI libraries other than React, and describes the resulting router as having zero dependencies. In this repository that logic lives under `packages/react-router/lib/router/`; React-specific code (components, hooks) sits on top of it.

## History is an implementation detail

History was inlined into the router as a single file and treated as internal, not as a standalone public package. Reasons given:

- In a data-aware router, PUSH/REPLACE navigations go `router.navigate -> load data -> update state -> update history`, while POP goes `update history -> router.navigate -> load data -> update state`. The router stays the public API.
- Keeping history internal leaves room to adopt the browser Navigation API "in a non-breaking manner".

## The router instance lives outside React

An earlier design created a router singleton inside a component on first render. It made tests need a module-scope reset, ignored conditional or HMR-added JSX `<Route>`s, and behaved unexpectedly with external state. The router singleton was lifted "into user-land": users create the router outside the React tree and pass it to `RouterProvider`, in line with React's `useSyncExternalStore` model.

## Platform primitives over custom parameters

The separate `signal` argument to loaders and actions was dropped "because an incoming `Request` already has its own signal". Code should use `request.signal`. There is also a single error boundary concept (`errorElement` / `useRouteError`) instead of separate error and catch boundaries: anything thrown ends up in the error boundary.
