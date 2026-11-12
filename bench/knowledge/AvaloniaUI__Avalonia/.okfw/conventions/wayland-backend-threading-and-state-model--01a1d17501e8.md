---
id: "01a1d175-01e8-7880-a03a-8ec044d0f624"
title: "Wayland backend threading and state model"
type: "Guideline"
tags:
  - "wayland"
  - "linux"
  - "threading"
  - "concurrency"
  - "architecture"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "The Wayland backend runs all Wayland work on a dedicated worker thread that is also the render thread, forbids shared state between it and the UI thread, and keeps persistent state so it can survive compositor restarts."
x:
  paths: ["src/Avalonia.Wayland/**"]
  source: ["src/Avalonia.Wayland/README.md", ".github/copilot-instructions.md"]
---

# Wayland backend threading and state model

The project's contribution guidance tells code reviewers to apply `src/Avalonia.Wayland/README.md` to changes under `src/Avalonia.Wayland/**`. This concept covers its threading and state rules; protocol rules are in [Wayland protocol rules](./wayland-protocol-and-nwayland-rules--01a1d1750206.md).

## Threading rules

The README states: **"NO CROSS-THREAD VARIABLE ACCESS. MESSAGING ONLY."**

- All Wayland interaction runs on a dedicated Wayland worker thread, which is also Avalonia's render thread.
- UI-thread objects must never directly access fields of Wayland-thread objects, except at initial creation or when passing values to constructors.
- Wayland-thread objects must never directly read fields of UI-thread objects. The README rules out volatile fields, locks, and any other "safe" shared state.
- UI-to-Wayland communication goes through code-generated proxies that route calls via `WaylandWorker.PostOob()` / `PostWithCommit()` messages. Drag-and-drop and clipboard are a stated, temporary exception.
- Server objects (under `Server/`) must not have their internal state changed from UI-thread code. The UI thread may only `Post` and pass values into constructors.
- Most UI-to-Wayland commands travel inside composition batches, so the Wayland thread always sees a consistent UI state. Out-of-band commands exist for special cases that bypass the compositor commit cycle.
- All Wayland traffic uses a dedicated Wayland queue, so Avalonia can be embedded in another toolkit.

## Compositor restarts and resources

On Wayland the compositor is **expected** to crash and restart during normal use. Avalonia therefore keeps its own "persistent" state of surfaces and resources (`Server/Persistent`) that can be re-uploaded on restart. Entities bound to a connection (`Server/Transient`) are ephemeral, and all resources are treated as transient and re-created as needed. Crash recovery is not yet supported with an externally created `wl_display`.

## Render timer

The compositor tells the app when to render through per-toplevel frame callbacks, so the render timer is triggered by those callbacks rather than being a real timer. Code that needs the timer to act (for example for a new surface) must wake it explicitly. A 20 FPS fallback timer exists for oversights and is meant to be removed eventually.
