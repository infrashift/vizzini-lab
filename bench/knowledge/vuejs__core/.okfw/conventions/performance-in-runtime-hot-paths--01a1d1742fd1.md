---
id: "01a1d174-2fd1-7a32-aeba-cc20a00c6d61"
title: "Performance in runtime hot paths"
type: "Guideline"
tags:
  - "performance"
  - "renderer"
  - "benchmarks"
  - "runtime"
created: "2026-11-12T14:30:14-06:00"
timestamp: "2026-11-12T14:30:14-06:00"
description: "Changes to the virtual DOM renderer, component instantiation and Vapor render effects need extra performance scrutiny, and performance claims need benchmarks."
x:
  paths: ["packages/runtime-core/src/renderer.ts", "packages/runtime-core/src/component.ts", "packages/runtime-core/src/**", "packages/runtime-vapor/src/renderEffect.ts", "packages/runtime-vapor/src/**", "packages-private/benchmark/**", "scripts/bench.ts"]
  source: [".github/contributing.md", ".github/maintenance.md", "AGENTS.md"]
---

# Performance in runtime hot paths

The docs single out "hot paths" where code runs on every update and small costs multiply:

- the virtual DOM renderer, `runtime-core/src/renderer.ts` (including the vdom patch function and component updates);
- component instantiation code;
- in Vapor mode, `renderEffect`.

Review expectations for changes in these areas:

- **Consider the performance impact** of any change, and whether the bug being fixed justifies the cost. A fix for a rare edge case that adds disproportionate overhead should be reworked to reduce it.
- **Dev-only branches are cheaper to accept.** If the new code only runs in a `__DEV__` branch, performance matters less (see the bundle-size concept).
- **Check bundle size as well as speed.** The review guidelines ask whether a hot-path runtime change could regress bundle size.
- **Performance claims need evidence.** A refactor that claims to improve performance should come with benchmarks or similarly direct evidence, unless the improvement is self-explanatory. Refactors that are purely stylistic are not accepted on performance grounds without that evidence.

Benchmark tooling described in the contributing guide:

- Node benchmarks run with `pnpm bench --run` and save results under `temp/bench`; after a change, `pnpm bench-compare --run` compares against the saved baseline without overwriting it. A new baseline is needed when benchmark names or measured workloads change.
- Node benchmark files import `test` from `scripts/bench.ts` and use its `benchmark` fixture. Imported functions should be cached in local variables before measurement to avoid Vite module-runner overhead skewing results.
- Browser benchmarks compare implementations within each scenario using Vitest's `bench.compare()`.

When a change touches runtime hot paths, the author is expected to explain the trade-offs clearly and to run the broader validation suite, not only the narrowest test.
