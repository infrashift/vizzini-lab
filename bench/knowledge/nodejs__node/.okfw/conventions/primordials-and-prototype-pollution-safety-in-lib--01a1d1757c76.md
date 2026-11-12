---
id: "01a1d175-7c76-74ce-bd4f-bdf8227d8e0b"
title: "Primordials and Prototype-Pollution Safety in lib"
type: "Guideline"
tags:
  - "javascript"
  - "primordials"
  - "security"
  - "performance"
  - "lib"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Core JavaScript in lib/ should use primordials and avoid implicit calls to user-mutable built-ins, except where hot-path performance is explicitly favored."
x:
  paths: ["lib/**/*.js"]
  source: ["doc/contributing/primordials.md", "doc/contributing/writing-tests.md"]
---

# Primordials and Prototype-Pollution Safety in lib

`lib/internal/per_context/primordials.js` captures the JS built-ins at startup so core modules do not look them up from the global proxy, which user code can mutate. Primordials are internal only; user code cannot rely on them.

**Where the rule applies**

- New code should prefer primordials (e.g. `ArrayPrototypePush(arr, x)` instead of `arr.push(x)`).
- Exception: in `node:http`, `node:http2`, `node:tls` and `node:zlib`, performance and readability are deemed more important than resistance to prototype pollution.
- Rewriting existing code to primordials must be "done with care"; ping the owning team when a PR touches their subsystem.

**Patterns a reviewer should flag in core code**

- `for...of`, array destructuring (`const [a, b] = arr`) and spread (`[...arr]`, `f(...arr)`) on genuine arrays: they go through the user-mutable `Symbol.iterator`. Use indexed `for` loops, object destructuring (`const { 0: a } = arr`), `ArrayPrototypeSlice`, or `ReflectApply`.
- `Promise.all/allSettled/any/race` and `PromisePrototypeFinally`: use the `SafePromise*` variants (`SafePromiseAllReturnVoid`, `SafePromiseAllReturnArrayLike`) or `try/finally`. Do not hand `SafePromiseAllReturnArrayLike` results to users, since they are not genuine arrays.
- Generators and async generators rely on user-mutable `next`; avoid them in core.
- String `match/replace/split/search` and `RegExp` methods that look up `exec` or flags; prefer `RegExpPrototypeExec`, `RegExpPrototypeSymbolReplace`, and `hardenRegExp`.
- Property descriptors and `Proxy` handlers must be null-prototype objects (`{ __proto__: null, ... }`, or `kEnumerableProperty`).
- `instanceof` is not recommended; check for properties or methods instead.
- Safe classes (`SafeSet`, `SafeMap`, ...) must not be exposed to user land.

**Performance caveat**

Some primordials regress V8 performance in hot paths: `ArrayPrototypePush/Pop/Shift/Unshift`, `FunctionPrototypeBind/Call`, `SafeArrayIterator`, `SafeStringIterator`, the `SafePromise*` combinators, `SafePromisePrototypeFinally`, and `ReflectConstruct`. Use `() => {}` rather than `FunctionPrototype` for no-ops. For PRs touching a hot code path, "use extra caution and run extensive benchmarks".

`lib` uses only a selected subset of ES.Next features for performance reasons (tests may use more).
