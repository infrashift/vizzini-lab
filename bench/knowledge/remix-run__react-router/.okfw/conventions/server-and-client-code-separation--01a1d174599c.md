---
id: "01a1d174-599c-757b-b63d-004d2b84268a"
title: "Server and Client Code Separation"
type: "Guideline"
tags:
  - "security"
  - "bundling"
  - "vite"
  - "server-only"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "Server-only code must be excluded from client bundles by explicit marking and build-time errors, never by relying on treeshaking."
x:
  paths: ["packages/react-router-dev/vite/**", "packages/react-router/lib/dom/ssr/**", "packages/react-router/lib/dom/server.tsx"]
  source: ["decisions/0009-do-not-rely-on-treeshaking-for-correctness.md", "decisions/0010-splitting-up-client-and-server-code-in-vite.md", "docs/api/framework-conventions/server-modules.md", "docs/how-to/security.md"]
---

# Server and Client Code Separation

Mixing server and client code in one route file is convenient, but the framework must guarantee that server-only code never reaches the client. The docs give two reasons: it "prevents secrets available to the server from leaking into client" and stops the client from crashing on code that expects a server.

## Do not rely on treeshaking for correctness

Decision 0009 is explicit: "Do not rely on implicit, cross-module treeshaking for correctness." Treeshaking is "an imperfect optimization", bundlers may do less of it without a major version bump, and Vite's dev server does not do cross-module treeshaking at all. "Your code should already be correct before treeshaking is applied."

Instead the build must:

- Forcibly remove server-only route exports (`loader`, `action`, `headers`) from route modules and then explicitly run a dead-code elimination pass.
- Explicitly mark server-only code and throw a build-time error if it is still referenced by the client.

## `.server` modules

- Any file with a `.server` extension or inside a `.server` directory is excluded from the client module graph; "The build will fail if any code in a `.server` file or `.server` directory accidentally ends up in the client module graph."
- Exports are assumed client-safe unless explicitly marked server-only; route exports like `loader` and `action` are the known exception.
- Route modules must not be marked `.server` or `.client`, because they are referenced from both graphs; doing so causes build errors.

## Design goals a change should keep

Decision 0010 lists the goals: simple and robust exclusion of server code, compile-time errors over runtime errors, type safety, and no performance cost in common cases. Checking `.server` modules only needs the module path, with no AST parsing, which is why it is fast. The team rejected built-in "compile-time magic" for mixed modules because AST-manipulating transforms are more error-prone and bugs there "could open the door to leaking server code into the client". Expression-level separation is left to the external `vite-env-only` plugin.

## Inline scripts and CSP

The security guide states that every API that renders inline `<script>` elements must accept a `nonce` for Content-Security-Policy: `<Scripts>`, `<ScrollRestoration>`, `<ServerRouter>`, and React's server render functions. A new API that emits inline scripts should follow the same pattern.
