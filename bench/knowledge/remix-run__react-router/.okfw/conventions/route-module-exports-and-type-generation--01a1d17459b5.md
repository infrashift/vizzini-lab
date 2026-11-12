---
id: "01a1d174-59b5-7a4a-9725-ad10bf2b34e6"
title: "Route Module Exports and Type Generation"
type: "Guideline"
tags:
  - "types"
  - "typegen"
  - "route-modules"
  - "typescript"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "Route modules keep separate named exports so treeshaking and HMR work, and route-specific types come from generated code for every route config."
x:
  paths: ["packages/react-router-dev/typegen/**", "packages/react-router-dev/config/**", "packages/react-router-dev/vite/**"]
  source: ["decisions/0012-type-inference.md", "decisions/0010-splitting-up-client-and-server-code-in-vite.md"]
---

# Route Module Exports and Type Generation

The type inference decision sets how route modules are shaped and how their types are produced. Other decisions about the dev tooling add constraints that changes to `@react-router/dev` should keep.

## Keep the route export API

- "Keep the route module export API as is." Route modules export separate values for `loader`, `clientLoader`, `action`, `ErrorBoundary`, the `default` component and so on. The stated reason is that "standard transforms like treeshaking and React Fast Refresh (HMR) work out-of-the-box", and keeping the API avoids breaking changes for users upgrading.
- The build tooling depends on this shape. Server-only exports (`loader`, `action`, `headers`) are removed from client builds by export name before dead-code elimination (see the server/client separation concept).

## Route-specific args instead of generic hooks

- Generic hooks like `useParams`, `useLoaderData` and `useActionData` are defined once and cannot infer types for a specific route. So route exports receive route-specific arguments (`params`, `loaderData`, `actionData` as component props, and typed loader args).
- The hooks stay for backwards compatibility. The long-term aim is to deprecate them, with type-safe alternatives designed for edge cases.

## Typegen for all routes

- TypeScript cannot use the filesystem for inference, so types based on file paths need code generation.
- To avoid two inference code paths, React Router "treats any value returned by `routes.ts` the same". It does not assume how the routes were built and runs typegen in all cases.
- Types for each route module are generated into a gitignored `.react-router` directory.

## Dev tooling performance

- Decision 0010 prefers cheap checks: `.server` detection uses only the module path and needs no AST parsing, to "avoid performance degradation for common cases".
