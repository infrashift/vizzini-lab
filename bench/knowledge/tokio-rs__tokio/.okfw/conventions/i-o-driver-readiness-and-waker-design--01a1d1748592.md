---
id: "01a1d174-8592-7716-bebf-b71afae3bd1f"
title: "I/O driver readiness and waker design"
type: "Guideline"
tags:
  - "architecture"
  - "io"
  - "concurrency"
  - "async"
  - "design"
created: "2026-11-12T14:30:36-06:00"
timestamp: "2026-11-12T14:30:36-06:00"
description: "Tokio's I/O driver uses edge-triggered readiness, tracks known readiness per resource, removes waiters on drop and uses a tick to avoid lost wakeups."
x:
  paths: ["tokio/src/runtime/io/**", "tokio/src/io/**", "tokio/src/net/**"]
  source: ["tokio/docs/reactor-refactor.md", "README.md"]
---

# I/O driver readiness and waker design

`tokio/docs/reactor-refactor.md` is a design document for a refactor of the I/O driver (the reactor that the README describes as "backed by the operating system's event queue (epoll, kqueue, IOCP, etc...)"). It was written for an older release and contains open TODOs, so details such as names may differ from the current code, but it explains invariants a reviewer of the I/O driver should keep in mind.

**Edge-triggered readiness**

"Because Tokio uses **edge-triggered** notifications, the I/O driver only receives readiness from the OS once the ready state **changes**." The driver therefore tracks each resource's known readiness, which "helps prevent syscalls when the process knows the syscall should return with `EWOULDBLOCK`." An operation awaits readiness, tries the syscall, and on `WouldBlock` clears readiness and waits again.

**Waiters and cancellation**

Waiters are kept in an intrusive linked list in `ScheduledIo`, each with its own interest set, so many tasks can wait on one resource with different interests. When the future returned by `readiness()` "is dropped early, it is essential that the waker is removed from the list. This prevents leaking memory." Changes to waiter handling must keep this cancel-on-drop cleanup.

**Avoiding lost wakeups**

If a readiness event arrives between the syscall returning `WouldBlock` and readiness being cleared, the next wait could block forever. The design prevents this with a driver "tick": each readiness event carries the tick, and "readiness is only cleared if the current `tick` matches the `tick` included in the `ReadyEvent`." Readiness, tick, generation and a shutdown bit are packed into one atomic `usize` so they update together.

**Poll-based traits**

`AsyncRead`/`AsyncWrite` are poll based, so they cannot use the intrusive list or cancel interest. `ScheduledIo` keeps one dedicated waker per direction for them. For this reason they may only be implemented for resource types themselves, not for `&Resource`: concurrent use through shared references "would result in deadlocks", and storing a `Vec<Waker>` instead "would result in memory leaks." A change that implements these traits for a shared reference to an I/O resource conflicts with this design.
