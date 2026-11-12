---
id: "01a1d175-9f94-75b1-be86-c45189b2b279"
title: "Async Safety and Sync/Async Boundaries"
type: "Guideline"
tags:
  - "async"
  - "concurrency"
  - "orm"
  - "threads"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "Rules for code that crosses Django's sync/async boundary: async-unsafe parts, sync_to_async thread sensitivity, database connections, and dual-mode views and middleware."
x:
  paths: ["django/core/handlers/**", "django/db/**/*.py", "django/views/**", "django/middleware/**", "django/utils/asyncio.py", "django/test/**"]
  source: ["docs/topics/async.txt"]
---

# Async Safety and Sync/Async Boundaries

Django supports async views and a fully async request stack under ASGI. Async support for the ORM and other parts is still partial. The async documentation states these rules.

**Async-unsafe code**
- Some parts of Django have global state that is not coroutine-aware. These are "async-unsafe" and are protected from running in an async environment. The ORM is the main example.
- Calling them from a thread with a running event loop raises `SynchronousOnlyOperation`. This also happens when a sync function is called directly from async code without `sync_to_async`, because the thread still has an active event loop.
- The fix is to move the async-unsafe calls into their own sync function and call that through `asgiref.sync.sync_to_async`.
- The `DJANGO_ALLOW_ASYNC_UNSAFE` escape hatch can cause data loss or corruption under concurrent access. It must not be used in production.

**Adapters and threads**
- `async_to_sync` and `sync_to_async` from `asgiref` (itself a Django project package) adapt the calling style. Thread-locals and contextvars are preserved across the boundary.
- `sync_to_async` defaults to `thread_sensitive=True`, which runs all thread-sensitive sync code in one shared thread. This exists because database adapters must be used in the thread that created them, and much existing Django code assumes everything runs in the same thread.
- Sync code always runs in a different thread from the async code that calls it. Don't pass raw database handles or other thread-sensitive references across the boundary. For example, `await sync_to_async(connection.cursor)()` fails, so wrap all database access in a helper function instead.

**ORM and transactions**
- Every `QuerySet` method that runs SQL has an `a`-prefixed async variant, and `async for` works on all QuerySets. Model methods that use the database have async variants such as `asave()`.
- Transactions do not yet work in async mode. Code that needs them should be a single sync function called through `sync_to_async`.
- Persistent connections (`CONN_MAX_AGE`) should be disabled in async mode.

**Views, decorators and middleware**
- Django detects async views with `inspect.iscoroutinefunction`. Anything that returns a coroutine by other means must use `inspect.markcoroutinefunction`.
- For class-based views, the HTTP method handlers are async, not `__init__()` or `as_view()`.
- The listed view decorators support both sync and async views.
- Each sync/async switch costs about a millisecond. Synchronous middleware in front of an async view forces a thread per request and can remove the benefit of async, so middleware can be written to support both modes.
- When a client disconnects, the view receives `asyncio.CancelledError`. Code that catches it for cleanup should re-raise it.
