---
id: "01a1d175-01ca-7d52-893b-e461a8bd3ad9"
title: "COM reference management in Avalonia.Native"
type: "Guideline"
tags:
  - "native"
  - "macos"
  - "com"
  - "memory"
  - "resource-management"
created: "2026-11-12T14:31:08-06:00"
timestamp: "2026-11-12T14:31:08-06:00"
description: "The macOS native backend must never store raw COM pointers; retained references use ComPtr, ComObjectWeakPtr or ComStaticPtr, and avn.idl methods return interfaces through HRESULT out-parameters."
x:
  paths: ["native/Avalonia.Native/**", "src/Avalonia.Native/**"]
  source: ["native/Avalonia.Native/README.md", ".github/copilot-instructions.md", "docs/macos-native.md"]
---

# COM reference management in Avalonia.Native

`native/Avalonia.Native` is the macOS platform backend, written in Objective-C++ and connected to the managed side through COM interfaces. COM types are usually prefixed `IAvn` (interfaces) or `Avn` (implementations). They all derive from `IUnknown` and use `AddRef`/`Release` reference counting. The project's contribution guidance tells code reviewers to apply this README to any change under `native/Avalonia.Native/**`.

## The core rule

**No raw COM pointer should ever be stored in class fields, instance variables, closures, or containers.** Raw COM pointers are only acceptable as function parameters and as local variables that live for the current call.

## Required wrappers (from `inc/comimpl.h`)

- **`ComPtr<T>`**: an owning reference, for any COM pointer the holder needs to keep alive. `ComPtr<IAvnWindow> _window;` is correct; `IAvnWindow* _window;` is wrong.
- **`ComObjectWeakPtr<T>`**: a non-owning weak reference to a `ComObject`-derived internal implementation. Read it with `tryGet()`, which returns a `ComPtr<T>` that is null if the object has been destroyed, and null-check the result before use.
- **`ComStaticPtr<T>`**: for static or global singletons that live for the whole process. It deliberately does **not** call `Release` in its destructor, to avoid crashes during teardown. Assign it with `set()`.
- **`comnew<T>(args...)`**: creates a COM object already wrapped in a `ComPtr<T>`. A `ComObject`-derived `new T()` starts with refcount 1, and `comnew` takes ownership without an extra `AddRef`. Prefer it to `ComPtr<T>(new T(...), true)`.

## Return-value convention in `avn.idl`

By COM convention, any interface returned from a COM call has already been `AddRef`ed and the caller must release it. The `IFoo* GetFoo()` shape makes this easy to leak, so all methods in `avn.idl` should use `HRESULT GetFoo(IFoo** ppv)` instead. New IDL methods that return an interface pointer directly go against this convention.

## Objective-C objects

`NSObject*` references are ref-counted by ARC. They look like raw pointers but need no manual wrapping when stored in fields. The COM rules above apply only to COM types.
