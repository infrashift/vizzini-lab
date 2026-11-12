---
id: "01a1d175-2825-7ee4-bf06-391940f7a581"
title: "BPF datapath unit and integration tests"
type: "Guideline"
tags:
  - "testing"
  - "bpf"
  - "datapath"
  - "c"
created: "2026-11-12T14:31:18-06:00"
timestamp: "2026-11-12T14:31:18-06:00"
description: "Datapath changes are tested with C test programs in bpf/tests run through BPF_PROG_RUN, using CHECK/PKTGEN/SETUP programs and macro-based mocking."
x:
  paths: ["bpf/tests/**", "bpf/**/*.c", "bpf/**/*.h"]
  source: ["Documentation/contributing/testing/bpf.rst", "Documentation/contributing/development/bpf_tests.rst", "Documentation/contributing/development/datapath_config.rst"]
---

# BPF datapath unit and integration tests

The BPF datapath has its own test framework. Tests are written in C and run in the kernel through `BPF_PROG_RUN` without attaching to real hooks. Results show up as Go test output. Run them with `make run_bpf_tests` (optionally `BPF_TEST="<name>"`); this needs Docker on Linux. The docs also describe running them inside a Little VM Helper VM.

**Structure rules:**
- Every `.c` file in `bpf/tests` is a test program that is compiled and run on its own. Other files such as `.h` are ignored and can hold shared code.
- Each `.c` file needs at least one `CHECK(type, name)` program and should start with `#include "common.h"`.
- Each `CHECK` program starts with `test_init()` and ends with `test_finish()`. No explicit `return` is needed.
- Function names must be unique for compilation. The kernel uses the first 15 characters, and they populate tail call maps.
- Sub-tests use the `TEST` macro and share setup within one program run.

**State is shared between tests in a file.** "BPF maps are not cleared between `CHECK` programs in the same file," and tests in a file run in alphabetical order of their names. If tests should be isolated, they must clean up map state or use unique data.

**Integration tests across tail calls** use `PKTGEN` (build the context/packet) and `SETUP` (further setup and the tail call) before the `CHECK` program of the same name. `CHECK` finds the `SETUP` return code as a `u32` prepended to the packet data, so the real packet starts at `data + 4`.

**Mocking**: define a function with the same signature, `#define original_name mock_name`, then include the file under test.

**Limitations to keep in mind when reviewing tests:**
- Test code must pass the verifier, including the complexity limit on older kernels. Heavy setup should go in a separate `SETUP` program.
- `test_log`, `test_fail` and similar can be used only in the main program or a `TEST` block.
- `test_fail_now()`, `test_fatal()` and `test_skip_now()` cannot be used inside both a `TEST` and a `for`/`while`/`switch` block, because they use `break`.
- Sub-test names and log messages are limited to 127 characters; log messages to 12 arguments.

Tests can override datapath config values with `ASSIGN_CONFIG()` after including the object under test.
