---
id: "01a1d175-7dda-7846-92b6-80bb35a3ca94"
title: "C++ Style Rules for src"
type: "Guideline"
tags:
  - "cpp"
  - "style"
  - "memory"
  - "src"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Node.js-specific C++ formatting, naming, ownership and casting rules that cpplint does not enforce and reviewers check by hand."
x:
  paths: ["src/**/*.cc", "src/**/*.h"]
  source: ["doc/contributing/cpp-style-guide.md", "src/README.md"]
---

# C++ Style Rules for src

Priority order: the Node.js C++ style guide, then the Google C++ Style Guide, then the ISO C++ Core Guidelines. `make lint-cpp` misses many Node-specific rules, so reviewers check these manually.

**Formatting and naming**

- Left-leaning pointers: `char* buffer;`.
- `//` comments only, starting uppercase and ending with a period (old `/* */` comments may be updated when touching nearby code).
- 2-space block indentation; 4 spaces for statement continuations, with operators before the line break; namespaces are not indented.
- Align function arguments vertically, or break after `(` and indent 4 spaces.
- `PascalCase` for functions, methods and classes, except simple accessors `property_name()` / `set_property_name()`.
- `snake_case` for locals and parameters, `snake_case_` for private fields, `snake_case` for C-like structs.
- `template <typename T>` with a space; use const-correctness whenever possible.

**Memory and ownership**

- `Malloc()`/`Calloc()`/`Realloc()` from `util.h` abort on OOM; `Unchecked*` variants return `nullptr` and must be checked.
- Use `nullptr`, never `NULL` or `0`, and compare explicitly (`if (foo == nullptr)`).
- Represent ownership with `std::unique_ptr` (preferred) or `std::shared_ptr`; never `std::auto_ptr`.
- Avoid non-const references for outputs; pass a pointer so mutation is visible at the call site.
- Use `AliasedBuffer` to modify TypedArray data from C++.
- `MaybeStackBuffer`, `Utf8Value`, `TwoByteValue` and `BufferValue` are the helpers for small temporary data and string contents; `OnScopeLeave()` runs cleanup when leaving a scope.

**Other rules**

- Casts: `static_cast` when valid, `reinterpret_cast` only when necessary, no C-style casts. `dynamic_cast` does not work because Node.js is built without RTTI.
- Prefer explicit types over `auto`; use `auto` only where the type name is noisy, obvious or unimportant.
- Do not include `foo.h` when `foo-inl.h` is already included.
- Node.js is built without C++ exception handling: `throw`, `try` and `catch` will break.
- `CHECK*` macros are always enabled and abort the process; use `DCHECK*` for debug-only checks, and `UNREACHABLE()` for impossible paths.
