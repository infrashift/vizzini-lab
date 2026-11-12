---
id: "01a1d174-2f92-767a-b42c-c9de97e0ebf6"
title: "Package boundaries and cross-package imports"
type: "Guideline"
tags:
  - "architecture"
  - "monorepo"
  - "imports"
  - "dependencies"
created: "2026-11-12T14:30:14-06:00"
timestamp: "2026-11-12T14:30:14-06:00"
description: "Vue core is a monorepo of layered packages, and code may only cross package boundaries through package-name imports that respect the compiler/runtime split."
x:
  paths: ["packages/*/src/**", "packages/*/package.json"]
  source: [".github/contributing.md", "AGENTS.md", "packages/shared/README.md", "packages/runtime-core/README.md", "packages/reactivity/README.md"]
---

# Package boundaries and cross-package imports

The repository hosts its public packages under `packages/` and private tools, playgrounds and type-test support under `packages-private/`. The documented dependency graph is layered:

- Runtime side: `runtime-dom` and `runtime-vapor` depend on `runtime-core`, which depends on `reactivity`.
- Compiler side: `compiler-dom` and `compiler-vapor` depend on `compiler-core`; `compiler-sfc` depends on `compiler-core`, `compiler-dom` and `compiler-vapor`.
- `vue` (the full build) sits on top and pulls in `compiler-sfc`, `compiler-dom`, `runtime-dom`, `compiler-vapor` and `runtime-vapor`.
- `shared` holds internal utilities used across packages, especially environment-agnostic helpers used by both runtime and compiler packages.

Rules a reviewer should check on any change that adds an import:

- **No relative paths across packages.** Import by package name (usually with the `@vue/` prefix, e.g. `import { h } from '@vue/runtime-core'`). If the item is not exported, export it from the source package first and import it at the package level. Aliases for this are configured in `tsconfig.json` paths and `scripts/aliases.js`.
- **Compiler and runtime never import each other.** Anything that both sides need belongs in `@vue/shared`.
- **Declare real dependencies.** If package A has a non-type import from package B, or re-exports a type from B, then B must be listed as a dependency in A's `package.json`. Packages are externalized in the esm-bundler/CJS builds and in the `.d.ts` files, so the dependency must actually be installed when consumed from a registry.

Package roles that constrain where code belongs:

- `runtime-core` is platform-agnostic (renderer, components, JS APIs); platform code such as native DOM attributes, properties and events belongs in `runtime-dom`. `runtime-core` is published for typing and custom renderers, not for direct app use.
- `reactivity` can be used standalone and framework-agnostically; user-facing renderers should re-export all of its APIs.
- `compiler-core` is the platform-agnostic, extensible compiler base; browser-specific plugins go in `compiler-dom`, SSR-optimized codegen in `compiler-ssr`.

Before reviewing a change, first decide whether it belongs to runtime, compiler, SFC, SSR, type declarations or tooling, and check that the code landed in the matching package.
