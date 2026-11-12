---
id: "01a1d176-9213-72b2-b9b2-2ad1fa7337d1"
title: "Error classes and codes"
type: "Guideline"
tags:
  - "errors"
  - "api"
created: "2026-11-12T14:32:51-06:00"
timestamp: "2026-11-12T14:32:51-06:00"
description: "undici's typed error hierarchy, the stable name/code contract on each error, and why callers should match on error.code."
x:
  paths: ["lib/core/errors.js", "lib/mock/mock-errors.js", "types/errors.d.ts"]
  source: ["docs/docs/api/Errors.md", "docs/docs/api/MockErrors.md", "docs/docs/api/Dispatcher.md", "docs/docs/api/api-lifecycle.md", "docs/docs/best-practices/writing-tests.md"]
---

# Error classes and codes

## The hierarchy

undici "raises typed error objects so that failures can be distinguished programmatically". Every error class is exported through the `errors` namespace. All errors, **except `HTTPParserError`**, extend `UndiciError`.

Each class documents a fixed `name` and `code`, for example:

| Class | `code` |
|---|---|
| `UndiciError` | `UND_ERR` |
| `ConnectTimeoutError` | `UND_ERR_CONNECT_TIMEOUT` |
| `HeadersTimeoutError` | `UND_ERR_HEADERS_TIMEOUT` |
| `BodyTimeoutError` | `UND_ERR_BODY_TIMEOUT` |
| `InvalidArgumentError` | `UND_ERR_INVALID_ARG` |
| `RequestAbortedError` | `UND_ERR_ABORTED` (name `AbortError`) |
| `InformationalError` | `UND_ERR_INFO` |
| `ClientDestroyedError` | `UND_ERR_DESTROYED` |
| `ClientClosedError` | `UND_ERR_CLOSED` |
| `SocketError` | `UND_ERR_SOCKET` |
| `ResponseExceededMaxSizeError` | `UND_ERR_RES_EXCEEDED_MAX_SIZE` |
| `RequestRetryError` | `UND_ERR_REQ_RETRY` |

The docs describe each `name` and `code` as "Always" that value. The docs call the `code` string "stable", so renaming a code or changing which class is thrown for a condition changes a documented contract. Mock errors follow the same pattern (`MockNotMatchedError`, code `UND_MOCK_ERR_MOCK_NOT_MATCHED`).

## Cross-version matching

Because the bundled global dispatcher in Node.js "may come from a different undici version than the one you import directly", the docs recommend matching on `error.code` rather than `instanceof errors.UndiciError`. `UndiciError` and its subclasses are also designed to be reliable with `instanceof` across realms and undici versions: the check "is based on a well-known symbol rather than the prototype chain". A new error class should keep both properties: a distinct stable `code` and participation in that symbol-based `instanceof` check.

## Where specific errors are expected

- Calling any method on a destroyed `Client` "rejects or fails with a `ClientDestroyedError`".
- Aborting a request via signal yields `RequestAbortedError`.
- For HTTP/2, a GOAWAY frame emits `'disconnect'` with an error whose message is `HTTP/2: "GOAWAY" frame received` and code `UND_ERR_INFO`.
- Handler `onResponseError` callbacks receive errors and must not throw.
- Tests treat `HeadersTimeoutError`, `BodyTimeoutError` and `HTTPParserError` as conditions under which a disconnect is expected.
