---
id: "01a1d176-12a6-7c23-8aab-13a9c7a9dbe3"
title: "Error Handling Conventions"
type: "Guideline"
tags:
  - "fastify"
  - "errors"
  - "error-codes"
  - "error-handler"
created: "2026-11-12T14:32:18-06:00"
timestamp: "2026-11-12T14:32:18-06:00"
description: "How Fastify expects errors to be raised, coded, propagated through encapsulated error handlers, and documented."
x:
  paths: ["lib/errors.js", "lib/error-handler.js", "lib/error-serializer.js", "lib/error-status.js", "lib/reply.js", "types/errors.d.ts", "build/build-error-serializer.js"]
  source: ["docs/Reference/Errors.md", "docs/Reference/Hooks.md", "docs/Reference/Validation-and-Serialization.md", "docs/Reference/Routes.md"]
---

# Error Handling Conventions

## Philosophy

- "Fastify follows an all-or-nothing approach and aims to be lean and optimal. The developer is responsible for ensuring errors are handled properly."
- Uncaught errors in Node.js can cause memory and file-descriptor leaks; since they cannot all be processed sensibly, "the best way to deal with them is to crash." Core should not swallow them globally.
- "When using promises, attach a `.catch()` handler synchronously."
- Fastify catches errors thrown in synchronous and `async` route handlers "without hindering performance" and routes them to the default error handler (generic 500). Performance limits how much core will wrap.

## Coded errors

- Every framework error has a stable `FST_ERR_*` code, exposed through `Fastify.errorCodes` so applications can check `error instanceof Fastify.errorCodes.FST_ERR_...`.
- Each code is listed in the table in `docs/Reference/Errors.md` with description, how to solve, and discussion link. The docs describe it as "a table with all the error codes used by Fastify", so a new code without a row there leaves that list incomplete.

## Propagation rules

- Errors from hooks go through `done(err)` or a thrown error in async hooks.
- `setErrorHandler` is encapsulated: the closest handler in the plugin's context wins. Throwing inside a custom handler calls the parent handler.
- `onError` fires once for the first error; Fastify tracks error invocation to avoid infinite loops in the reply phases.
- The root (default) handler uses the `statusCode` and headers on the `Error` object; a custom handler does not get them set automatically.
- Throw `Error` instances. A non-`Error` value re-thrown from a plugin's handler "will not propagate to the parent context error handler" and is caught by the default handler instead.
- In a custom error handler, `reply.send(object)` is serialized and triggers `preSerialization`; strings, buffers, and streams are sent unserialized.

## Validation and constraint errors

- Validation error details are included in the response by default; the docs flag this as a security consideration and point to `setErrorHandler` for sanitizing.
- Custom validators must return `{ error }` instead of throwing when used with async `preValidation` hooks; throwing causes unhandled rejections that crash the app.
- Asynchronous route constraints should avoid returning errors in the callback; otherwise route selection may break or expose sensitive information.
