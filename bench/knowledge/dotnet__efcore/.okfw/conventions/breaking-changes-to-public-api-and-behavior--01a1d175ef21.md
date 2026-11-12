---
id: "01a1d175-ef21-71a1-82b4-c7bbb2b143bc"
title: "Breaking changes to public API and behavior"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "breaking-changes"
  - "csharp"
created: "2026-11-12T14:32:09-06:00"
timestamp: "2026-11-12T14:32:09-06:00"
description: "EF Core avoids source, binary and behavioral breaking changes; any break must be called out explicitly and only lands when its value greatly outweighs the pain to existing applications."
x:
  paths: ["src/**"]
  source: [".github/CONTRIBUTING.md"]
---

# Breaking changes to public API and behavior

`CONTRIBUTING.md` explains that EF Core "is used by many thousands of existing applications" and the team wants upgrading to be as easy as possible. A breaking change is one that makes an existing application break when it updates. "Each such breaking change must be explicitly called out and will only be approved if the value of making the change greatly outweighs the pain of breaking existing applications."

**API breaking changes** come in two forms:

- **Source breaking**: existing code no longer compiles against the new public API.
- **Binary breaking**: an assembly compiled against an older EF Core fails when run with the new one.

The guide's worked example shows what a reviewer should look for:

- Adding a parameter to a public constructor or method removes the old signature. That is both source and binary breaking.
- Making the new parameter optional (`string b = null`) fixes source compatibility but is still **binary** breaking, because compiled callers bind to the old signature, which no longer exists.
- Adding a new overload and having the old one delegate to it (`public Foo(string a) : this(a, null)`) is neither source nor binary breaking. This is the preferred shape: "where possible try to write code that is not breaking at all."

"Binary breaking changes, especially for database providers, can have lower impact and may be acceptable," but they still need to be identified.

**Behavioral breaking changes** happen "when the behavior of calling some API changes without the API itself changing." The guide's example: if `DbContext.Add` used to leave an entity in the `Added` state and now leaves it `Modified`, applications that expect `Added` may misbehave. These are "hard to identify and are one of the reasons testing is so important." Running all existing tests helps catch them, and good new tests help catch future ones.

**Review checklist**

- Any change to a public signature in `src/`: is it source breaking, binary breaking, or neither? Could an overload avoid the break?
- Any change in observable behavior of an existing API (state changes, generated SQL, exceptions): is it intentional and explicitly called out as a breaking change?
- Existing tests that had to be changed to pass can be a sign of a behavioral break.
