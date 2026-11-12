---
id: "01a1d174-2fb2-729e-b3c1-430696210e34"
title: "Bundle size, tree-shaking and __DEV__ branches"
type: "Guideline"
tags:
  - "performance"
  - "bundle-size"
  - "tree-shaking"
  - "dev-only"
created: "2026-11-12T14:30:14-06:00"
timestamp: "2026-11-12T14:30:14-06:00"
description: "Every change must justify its bundle-size cost, keep dev-only and compiler-only code out of production runtime builds, and stay tree-shakable."
x:
  paths: ["packages/*/src/**"]
  source: [".github/contributing.md", ".github/maintenance.md", "AGENTS.md", "packages/vue/README.md", "packages/runtime-vapor/README.md"]
---

# Bundle size, tree-shaking and __DEV__ branches

Bundle size matters, and a GitHub action compares the size change of every PR. The stated goal is to realize the change "with the smallest amount of code size increase", weighing size against the benefit. For a fix to a very niche edge case, the size and performance cost should be minimized so the fix remains a reasonable trade-off.

What a reviewer should check:

- **Dev-only code goes behind `__DEV__`.** Warnings, extra validation and other development diagnostics must sit in `__DEV__` branches so they are tree-shaken from production builds. Inside a dev-only branch, performance is less of a concern.
- **Runtime is more sensitive than compiler.** Size increases in runtime packages weigh more than the same increase in compiler code.
- **No accidental leakage into runtime builds.** A change must not pull dev-only or compiler-only branches into the runtime build. Some `@vue/shared` helpers are compiler-only and must not be used in runtime code, for example `isHTMLTag` and `isSVGTag`.
- **Added code should be tree-shakable** when the feature that needs it is not used.
- **Vapor interop stays optional.** In `runtime-vapor`, VDOM interop code paths must be guarded by `isInteropEnabled` (from `vdomInteropState.ts`) so they are removed when the interop plugin is not installed. Unconditional imports of, or calls to, `vdomInterop.ts` helpers outside such a check are not allowed.

Context on build flags: the `esm-bundler` builds leave prod/dev branches behind `process.env.NODE_ENV` guards for the consumer's bundler to replace, while global and esm-browser builds hard-code the prod/dev branches. The esm-bundler builds also expose compile-time feature flags (`__VUE_OPTIONS_API__`, `__VUE_PROD_DEVTOOLS__`, `__VUE_PROD_HYDRATION_MISMATCH_DETAILS__`) so applications can tree-shake unused features. New dev/prod-dependent code should fit this model rather than introduce its own switch.

If a change touches bundle size, the author should explain the trade-off, and `vp run size` is the listed command to measure it.
