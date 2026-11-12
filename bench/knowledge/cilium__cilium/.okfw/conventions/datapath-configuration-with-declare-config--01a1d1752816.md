---
id: "01a1d175-2816-7cb8-8fae-61099ef0bcbc"
title: "Datapath configuration with DECLARE_CONFIG"
type: "Guideline"
tags:
  - "bpf"
  - "datapath"
  - "configuration"
  - "c"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "BPF programs get agent-provided settings through DECLARE_CONFIG/CONFIG() runtime variables declared close to their use, not through new node_config defines or conditional includes."
x:
  paths: ["bpf/**/*.c", "bpf/**/*.h", "pkg/datapath/config/**", "pkg/datapath/loader/**"]
  source: ["Documentation/contributing/development/datapath_config.rst"]
---

# Datapath configuration with DECLARE_CONFIG

The datapath receives feature flags, addresses, timeouts, security IDs and other tunables from the agent when BPF programs are loaded. Historically this used `#define` statements generated at runtime and `#ifdef` blocks. Cilium is moving to read-only config variables that the verifier can use for dead-code elimination. This lets the BPF code be built and embedded into the agent at compile time, without shipping LLVM with the agent.

**How it works.**
1. Declare the value in C with `DECLARE_CONFIG(type, name, "description")`, for example in `bpf/include/bpf/config/lxc.h`.
2. Rebuild `bpf/`; `dpgen` generates a matching Go struct field (carrying the description as a comment) in `pkg/datapath/config`.
3. Set the value from the agent. This mostly happens in `pkg/datapath/loader` today (for `bpf_lxc.c`, typically in `endpointRewrites()`). It "needs to be done for every object that needs access to the variable."
4. Read the value in C only through the `CONFIG(name)` macro.

The value "is not a compile-time constant, so it cannot be used to control things like BPF map sizes or to initialize other global `const` variables."

**Guidelines a reviewer should check:**
- Avoid dead code: do not declare a variable in a header shared by several BPF objects if only one uses it. Put shared types in a separate header.
- Declare variables close to where they are used, for example in the header implementing the feature.
- Avoid conditional `#include` statements.
- New features use `DECLARE_CONFIG()` in the feature's header, included only by the BPF objects that use it. New config for existing features is declared as close as possible to the consuming code.
- When porting node configuration from `node_config.h`, try to narrow it to a `DECLARE_CONFIG()` in a header used by a few objects. Use `NODE_CONFIG()` only if none of the other cases apply. The "node configuration" pattern "is discouraged going forward."

**Defaults.** `ASSIGN_CONFIG()` sets a non-zero default from C and can be used only once per variable per compilation unit. That makes the value hard to override from tests, so the docs say to use it sparingly. The `#ifndef ..._CONFIG` override workaround for tests is described as "somewhat surprising"; prefer refactoring over it.
