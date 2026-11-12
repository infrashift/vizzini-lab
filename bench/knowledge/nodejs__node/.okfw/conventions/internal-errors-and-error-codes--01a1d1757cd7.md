---
id: "01a1d175-7cd7-7608-a108-b8a8a53ade42"
title: "Internal Errors and Error Codes"
type: "Guideline"
tags:
  - "errors"
  - "javascript"
  - "compatibility"
  - "lib"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Errors thrown by Node.js APIs must come from internal/errors with a permanent code, be documented in errors.md, and be tested by code rather than message."
x:
  paths: ["lib/**/*.js", "lib/internal/errors.js", "doc/api/errors.md", "test/parallel/test-internal-errors.js"]
  source: ["doc/contributing/using-internal-errors.md", "doc/contributing/cpp-style-guide.md", "src/README.md", "doc/contributing/writing-tests.md", "doc/contributing/collaborator-guide.md"]
---

# Internal Errors and Error Codes

Node.js errors carry a static, permanent `code` so users need not parse messages. Because users historically parsed messages, message changes on errors without a code are treated as breaking.

**Adding or using an error**

- New codes are added by appending to `lib/internal/errors.js` with `E('ERR_X', message, BaseClass)`; the message is a string with `util.format()` placeholders or a function returning a string.
- Code uses `const { ERR_X } = require('internal/errors').codes; throw new ERR_X(arg)` instead of `new TypeError(...)`.
- Switching an existing error to `internal/errors` must be treated as `semver-major`.
- Every new code that is used should be documented in `doc/api/errors.md`.
- Avoid changing a message's format after the error is created.

**Testing errors**

- Constant-string messages need no formatting test.
- Parameterized messages need tests in `test/parallel/test-internal-errors.js` covering every way the parameters shape the message.
- Tests at the call site should check `code` (and type), not the message: `assert.throws(fn, { code: 'ERR_X' })`. This limits test churn when messages change.

**Where validation and throwing happen**

- Arguments coming from user code are validated in the JavaScript layer and rejected with user-friendly `ERR_INVALID_*` errors, so the error points at the wrong argument rather than causing a crash deeper in the engine.
- C++ bindings assume pre-validated input and use `CHECK()` assertions; a failing `CHECK` aborts the process.
- Prefer not to throw JS errors from C++: return the data (or fill a context object) and construct the error in JS via `internal/errors`. When an API is implemented entirely in C++, validate there and use the `THROW_ERR_*` macros from `src/node_errors.h`.
- If a C++ function must throw, do it as close to the return to JavaScript as possible, not inside nested C++ calls.

**Compatibility**

Adding or removing errors thrown by a public API is a breaking change, although it is one of the listed exceptions that does not require a deprecation cycle.
