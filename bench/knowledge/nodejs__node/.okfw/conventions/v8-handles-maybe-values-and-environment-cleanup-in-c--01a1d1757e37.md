---
id: "01a1d175-7e37-7a92-8d4e-bf34287b6843"
title: "V8 Handles, Maybe Values, and Environment Cleanup in C++"
type: "Guideline"
tags:
  - "cpp"
  - "v8"
  - "libuv"
  - "resource-management"
  - "src"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Correctness rules for V8 handles, empty Maybe results, BaseObject lifetimes, libuv handles/requests and calling into JavaScript from src/."
x:
  paths: ["src/**/*.cc", "src/**/*.h"]
  source: ["src/README.md", "doc/contributing/cpp-style-guide.md"]
---

# V8 Handles, Maybe Values, and Environment Cleanup in C++

The C++ codebase README describes idioms whose misuse leads to crashes or leaks. Reviewers of `src/` changes should check these.

**Handles**

- `v8::Local` handles live only on the C++ stack; never store them in heap structures such as `std::vector<v8::Local<...>>` (use `v8::LocalVector`).
- A `HandleScope` (or `EscapableHandleScope`, to return one `Local`) must exist when creating Locals; binding functions already have one.
- `val.As<v8::X>()` is valid only if `val->IsX()` is true.
- Long-lived references use `v8::Global` (strong or weak); naming it `Persistent` is discouraged.

**Exceptions and `Maybe`**

- Any V8 call that may run JavaScript can fail: `Get`/`Set` can hit user getters on a modified `Object.prototype`, and execution can be terminated (e.g. `worker.terminate()`) at any point.
- Use `.To()` / `.ToLocal()` and return early on an empty result; propagate failure with `Maybe`/`MaybeLocal` return types in nested functions. After an empty `Maybe`, do not call further `Maybe`-returning APIs.
- `Check()`, `FromJust()`, `ToChecked()` and `ToLocalChecked()` crash on failure and are only acceptable when the operation is certain not to fail. The README notes that much existing code breaks this rule.
- Catch JS exceptions with `TryCatch`/`TryCatchScope`; if `HasTerminated()` is true, do not call `ReThrow()`.

**Object lifetime**

- JS-associated C++ objects subclass `BaseObject`; unwrap with `ASSIGN_OR_RETURN_UNWRAP`. Calling `MakeWeak()` in the constructor generally makes sense unless the event loop refers to the object.
- Use `BaseObjectPtr`/`BaseObjectWeakPtr` for references between BaseObjects.
- Calls into JS from the event loop go through `AsyncWrap::MakeCallback()`, with a `HandleScope` and `Context::Scope` entered first.

**Environment cleanup**

- `HandleWrap`/`ReqWrap` clean up their libuv objects automatically. A libuv handle not managed by `HandleWrap` must be closed with `env->CloseHandle()`, not `uv_close()`. A request not managed by `ReqWrap` must be tracked with `env->IncreaseWaitingRequestCounter()`/`DecreaseWaitingRequestCounter()`.
- Use cleanup hooks (`AddCleanupHook`/`RemoveCleanupHook`) for resources owned by an `Environment` or `Realm`; avoid starting async work inside them.
- Calling into JavaScript during cleanup is not allowed; outside `MakeCallback()`, check `env->can_call_into_js()` first.
