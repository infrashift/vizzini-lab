---
id: "01a1d174-b50e-732c-9d0c-49e63f4b1253"
title: "Function and Type Design Rules"
type: "Guideline"
tags:
  - "style"
  - "api-design"
  - "types"
  - "functions"
created: "2026-11-12T14:30:49-06:00"
timestamp: "2026-11-12T14:30:49-06:00"
description: "rust-analyzer's style rules for shaping functions, structs and parameters: preconditions in types, getters without setters, Config structs, and general borrowed types."
x:
  paths: ["crates/**", "lib/**"]
  source: ["docs/book/src/contributing/style.md"]
---

# Function and Type Design Rules

These rules come from the "Code" part of the style guide. They concern how code is structured, not cosmetics.

**Preconditions and control flow**
- Express preconditions in types and make the caller provide them: take `Walrus`, not `Option<Walrus>` with an early `return` on `None`.
- Do not split a precondition check from its use across functions. Prefer `string_literal_contents(s) -> Option<&str>` over `is_string_literal(s) -> bool` followed by slicing in the caller. "Non-local code properties degrade under change."
- Do not hide control flow inside callees. Put the `if cond { f() }` at the call site ("push ifs up").

**Fields, getters, constructors**
- If any value of a field is valid, make the field public. If there is an invariant, document it, enforce it in the constructor, make the field private, and add a getter. Never provide setters.
- Getters return borrowed data: `&str` and `Option<&str>`, not `String` clones or `&Option<String>`.
- Prefer the more general types: `&[T]` over `&Vec<T>`, `&str` over `&String`, `Option<&T>` over `&Option<T>`, `&Path` over `&PathBuf`.
- Prefer `Default` (even implemented by hand) to a zero-argument `new`. Do not invent "dummy" states just to implement `Default`.

**Parameters**
- Replace many optional or boolean parameters with a `Config` struct. Do not implement `Default` for that `Config`, and do not store it in state. Pass it explicitly.
- If a `bool`/`Option` parameter is always passed as a literal, split the function in two (`foo` / `foo_with_bar`) and extract shared code into a helper.
- Pass context parameters (threaded unchanged through calls) first. If there are several, pack them into a `Ctx` struct.

**Objects vs functions**
- Avoid "doer" objects in the outward API: `do_thing(a, b)`, not `ThingDoer::new(a, b).do()`. An internal `Ctx` struct is fine as an implementation detail.
- Avoid single-use helper functions. Use a block instead, unless you need `return` or `?`. Nested helpers go at the end of the enclosing function and only one level deep.

**Strings and paths**
- Use `OsString` when interfacing with OS APIs.
- Use `AbsPathBuf`/`AbsPath` over `std::path` so the long-lived, multi-project process does not leak its cwd.
