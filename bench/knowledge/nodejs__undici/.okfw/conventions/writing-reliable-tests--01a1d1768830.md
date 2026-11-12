---
id: "01a1d176-8830-772b-b853-8b66ef0b355a"
title: "Writing reliable tests"
type: "Guideline"
tags:
  - "testing"
created: "2026-11-12T14:32:48-06:00"
timestamp: "2026-11-12T14:32:48-06:00"
description: "Test patterns the undici docs prescribe: Node's test runner, an in-process server, cleanup via t.after, short keep-alive timeouts, and a guard against silent reconnects."
x:
  paths: ["test/**/*.js", "test/**/*.mjs"]
  source: ["CONTRIBUTING.md", "docs/docs/best-practices/writing-tests.md"]
---

# Writing reliable tests

## The standard test shape

The reproduction examples in `CONTRIBUTING.md` show the pattern tests are expected to follow:

- `'use strict'` and `node:test` (`test(...)`), typically with a `timeout` option and `t.plan(n)`.
- A server created with `createServer` from `node:http` inside the test, listening on port `0`, awaited with `once(server, 'listening')`. No external network services.
- Every resource registered for cleanup with `t.after(...)`: the server (`server.close()`, and `server.closeAllConnections?.()` where connections may linger) and the client, pool or agent (`client.close()`).
- Response bodies are consumed or discarded (`for await` over the body, `body.dump()`, or `response.body.cancel()` for `fetch`). The docs warn that unconsumed bodies can exhaust connections; see the "Response body consumption and client lifecycle" concept.
- Assertions through `t.assert.strictEqual` and similar.

## Keep-alive defaults slow tests down

`writing-tests.md` explains that undici's production defaults keep a socket open for a few seconds after a request, which makes automated tests slow. It recommends an `Agent` with `keepAliveTimeout: 10` and `keepAliveMaxTimeout: 10` (milliseconds) for tests. The `fetch` reproduction example in `CONTRIBUTING.md` likewise uses `new Agent({ keepAliveTimeout: 1 })`.

## Guard against silent reconnects

`Client` automatically reconnects after a socket error, so "a test can silently disconnect, reconnect, and still pass", which "could mask bugs like unexpected parser errors or protocol violations". The documented guard is a `'disconnect'` listener that fails the test when `!client.closed && !client.destroyed`. `close()` and `destroy()` emit `'disconnect'` too, which the guard tolerates.

The guard should be skipped when a disconnect is the expected behavior:

- signal aborts;
- server-side destruction (`res.destroy()`, `req.socket.destroy()`);
- client-side body destruction mid-stream;
- `HeadersTimeoutError` / `BodyTimeoutError`;
- successful upgrades (the socket is detached from the client);
- retry/reconnect tests where the disconnect triggers the retry;
- `HTTPParserError` from malformed responses.

A reviewer looking at a new `Client` test that exercises a happy path can reasonably ask whether a disconnect guard belongs there, and a test in the categories above should not carry one.
