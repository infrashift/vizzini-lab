---
id: "01a1d175-0206-7e8d-8187-ffc969112fd3"
title: "Wayland protocol and NWayland rules"
type: "Guideline"
tags:
  - "wayland"
  - "linux"
  - "protocol"
  - "review"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "Rules for binding Wayland globals, handling dynamic and multiple globals, dispatching wl_pointer frames in order, and using the NWayland bindings correctly."
x:
  paths: ["src/Avalonia.Wayland/**"]
  source: ["src/Avalonia.Wayland/README.md"]
---

# Wayland protocol and NWayland rules

These rules come from `src/Avalonia.Wayland/README.md`. Its general warning: do **not** assume things about Wayland protocols, which can be non-intuitive. Always check what the protocol says about a particular event. NWayland bindings carry protocol docs as C# XML comments, and the README points to the NWayland protocol XML (or the `.xml` files in the NuGet cache) as the reference.

## Globals and versions

- The compositor announces each global with the **maximum** version it supports. Bind with `Math.Min(compositorVersion, known-supported-version)`, and skip the global if that is below the minimum required.
- Objects created through a bound proxy inherit its version. Events from higher versions simply don't arrive.
- **Always specify the protocol version range Avalonia supports.** NWayland supporting a version in its bindings does not mean Avalonia is ready for it, even for "stable" protocols.
- Instead of comparing `Version`, use the generated `Is<Name>Available` properties to gate requests added in later versions.

## Globals come and go

- Globals such as `wl_seat` and `wl_output` can appear and disappear at runtime, and there can be several of the same type at once (for example multiple seats).
- Track globals by their registry `name` so they can be cleaned up on `global_remove`. **Do not assume singletons.**

## wl_pointer frames

- Pointer events accumulate until a `frame` event. **All events in a frame must be dispatched in arrival order.** A frame can hold a leave from surface A followed by an enter on surface B, and a fixed dispatch order sends events to the wrong surface.
- Combine multiple `axis` events in a frame into one scroll vector, but dispatch it at its correct position in the sequence.
- Frame state (focused sink, position, modifiers, pending events) belongs to each **pointer**, not the seat.
- Button codes are Linux `input-event-codes.h` values (`BTN_LEFT=0x110` and so on).

## NWayland usage

- Listeners are passed at bind or creation time. There is no `SetListener`, because of race conditions in libwayland-client.
- Use NWayland's generated enums with `.HasFlag()` or `==`. Don't touch `.value__`, and **don't re-declare protocol enums** even when a generated method takes `int`/`uint`.
- `WlFixed` converts with an explicit `(double)` cast.
- NWayland converts snake_case names to CamelCase, though XML docs may still use snake_case.
