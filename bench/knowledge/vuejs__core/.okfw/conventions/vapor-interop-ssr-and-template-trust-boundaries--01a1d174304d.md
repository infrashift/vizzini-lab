---
id: "01a1d174-304d-7e3b-ae97-4796c47cff44"
title: "Vapor interop, SSR and template trust boundaries"
type: "Guideline"
tags:
  - "vapor"
  - "ssr"
  - "security"
  - "interop"
  - "compiler"
created: "2026-11-12T14:30:15-06:00"
timestamp: "2026-11-12T14:30:15-06:00"
description: "Vapor and VDOM interop changes must be verified in both directions, Vapor runtime ships only as an esm-bundler browser build, and template source is a trusted input by policy."
x:
  paths: ["packages/runtime-vapor/src/**", "packages/compiler-vapor/src/**", "packages/server-renderer/src/**", "packages/compiler-ssr/src/**", "packages/compiler-core/src/**"]
  source: ["AGENTS.md", "packages/runtime-vapor/README.md", "SECURITY.md", ".github/contributing.md", "packages/server-renderer/README.md"]
---

# Vapor interop, SSR and template trust boundaries

The docs say comparatively little about these areas, so this concept collects the few stated rules rather than a full design.

**Vapor mode**

- `@vue/runtime-vapor` ships only an `esm-bundler` build, because Vapor mode requires an SFC build step and its runtime only runs in the browser. The `vue` package's `vue.runtime-with-vapor.esm-browser.js` inlines it for the SFC Playground only.
- Both `runtime-vapor` and `runtime-dom` sit on `runtime-core`; `compiler-vapor` sits on `compiler-core`. The usual compiler/runtime separation applies.
- VDOM interop paths in `runtime-vapor` must be guarded by `isInteropEnabled` so they tree-shake away when the interop plugin is absent; no unconditional imports or calls into `vdomInterop.ts` helpers.
- When reviewing interop or other cross-boundary changes, verify behavior in both directions: Vapor to VDOM and VDOM to Vapor.
- `renderEffect` is treated as a hot path alongside the VDOM renderer.
- Vapor tests should mirror template-compiled output and real usage rather than hand-written `setup` edge cases.

**Server-side rendering**

- `server-renderer` is the SSR package and `compiler-ssr` produces render functions optimized for SSR. The server-renderer README documents several output APIs (string rendering and Node, Web and simple streams); for example, environments without a global `ReadableStream` constructor should use `pipeToWebWritable` rather than `renderToWebStream`.

**Security stance on templates**

- The project does not treat XSS through template expressions as a valid attack vector: templates are trusted compilation input, and users are warned never to use untrusted content as template source. A reviewer should therefore not treat "untrusted template source can inject script" as a vulnerability to fix in the compiler; the docs state no further security rules for the codebase. Vulnerabilities are reported privately by email rather than in public issues.
