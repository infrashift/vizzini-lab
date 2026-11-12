---
id: "01a1d174-7a45-7c6c-b607-bbf601ed0ff9"
title: "Performance changes and how to measure them"
type: "Guideline"
tags:
  - "performance"
  - "benchmarking"
created: "2026-11-12T14:30:34-06:00"
timestamp: "2026-11-12T14:30:34-06:00"
description: "Performance contributions should be measured with Prettier's debug and benchmark tooling against a production build, and printer code should avoid the documented expensive patterns."
x:
  paths: ["src/**", "scripts/benchmark/**", "benchmarks/**"]
  source: ["CONTRIBUTING.md", "commands.md", "docs/plugins.md"]
---

# Performance changes and how to measure them

## Measuring

CONTRIBUTING.md describes the tooling to use when contributing a performance improvement:

- `--debug-repeat N` (or `PRETTIER_PERF_REPEAT`) repeats formatting `N` times and reports the average duration, which helps highlight hot functions in a profiler.
- `--debug-benchmark` uses `tinybench` for statistically significant measurements.
- `yarn perf <file>`, `yarn perf:inspect <file>` (with `node --inspect-brk` for the Chrome CPU profiler) and `yarn perf:benchmark <file>`.
- `scripts/benchmark/compare.sh` compares two or more commits or branches with hyperfine, for example `main` against a PR branch, optionally with `PRETTIER_PERF_FILENAME`.
- `node --prof`, `--prof-process` and `--trace-opt --trace-deopt` for deeper analysis.

These commands run against the built, compiler-optimized version under `NODE_ENV=production`. Prettier's own environment checks default to production and are removed during the build, so measurements on unbuilt sources are not representative.

## Patterns the docs call out as costly

- `conditionalGroup` "should be used as **last resort** as it triggers an exponential complexity when nested" (commands.md).
- AST traversal for comments and embedding walks every enumerable property unless the printer supplies `getVisitorKeys`; iterating non-node objects such as location data "is a waste of resources", and cyclic ASTs loop forever (plugins.md).
- The `embed` recursion is kept synchronous "for performance reasons"; async work belongs in the returned function.

## Caching

The API keeps a cache of file-system structure when loading configuration files and plugins, for performance. `clearConfigCache()` exists for integrations that know the file system changed.

## Regression testing

For changes with broad output impact, the project points to a separate regression-testing tool that runs on GitHub Actions.
