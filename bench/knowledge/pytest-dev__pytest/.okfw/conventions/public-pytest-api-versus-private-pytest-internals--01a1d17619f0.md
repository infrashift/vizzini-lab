---
id: "01a1d176-19f0-7045-9520-7f0f993c419b"
title: "Public pytest API Versus Private _pytest Internals"
type: "Guideline"
tags:
  - "architecture"
  - "api"
  - "nodes"
  - "compatibility"
created: "2026-11-12T14:32:20-06:00"
timestamp: "2026-11-12T14:32:20-06:00"
description: "Users and plugins are meant to reach pytest through the pytest namespace and documented constructors such as Node.from_parent, while _pytest internals and their constructors are private."
x:
  paths: ["src/pytest/__init__.py", "src/_pytest/**/*.py", "src/_pytest/nodes.py", "src/_pytest/python.py", "src/_pytest/mark/**"]
  source: ["doc/en/deprecations.rst", "doc/en/how-to/writing_plugins.rst", "doc/en/how-to/writing_hook_functions.rst", "doc/en/reference/reference.rst"]
---

# Public pytest API Versus Private _pytest Internals

pytest's code lives in two packages: `src/pytest/`, the public namespace users import, and `src/_pytest/`, which holds the builtin plugins and the implementation. The writing-plugins guide describes builtin plugins as "loaded from pytest's internal `_pytest` directory". The deprecations page shows where the project draws the line between public and private.

## Rules stated in the docs

- **Public names come from `pytest`.** The old `pytest.collect` module was removed from the public API and "all its names should now be imported from `pytest` directly instead".
- **Internal constructors are private.** Directly constructing `Mark`, `MarkDecorator`, `MarkGenerator`, `Metafunc`, `CallInfo`, `ExceptionInfo`, `Parser`, `OptionGroup` and `HookRecorder` is deprecated: "These constructors have always been considered private."
- **Nodes are built with `from_parent`.** Collection nodes are created with the named constructor `Node.from_parent(parent, name=...)`, called with keyword arguments only. This narrower API "intends to enable better/simpler refactoring of the collection tree".
- **Custom node `__init__` takes `**kwargs`.** Subclasses of `pytest.Item` and other nodes that override `__init__` should accept keyword-only extra arguments plus `**kwargs` and pass `**kwargs` to `super().__init__`, "to avoid hard-coding the arguments pytest can pass to the superclass".
- **No Item/Collector diamond inheritance.** A node type that is both an `Item` and a `Collector` "was never sanely supported". Use a separate collector that yields the item.
- **Do not expose implementation objects by accident.** `TerminalReporter.writer` was removed because it was "inadvertently exposed as part of the public API" and tied the plugin to one terminal writer. Plugins should use `TerminalReporter` methods.
- **Experimental APIs are labelled.** Some features (for example parts of the logging plugin and `record_xml_attribute`) are documented as experimental, and pytest has a `PytestExperimentalApiWarning` class.

## Review checks

- A new user-facing class or function should be exported through `pytest/__init__.py` and documented, not used by users from `_pytest.*`.
- A change that makes an internal attribute or constructor reachable from outside should be intentional, because once it is public it falls under the [Backward Compatibility and Deprecation Policy](./backward-compatibility-and-deprecation-policy--01a1d17619c0.md).
- Code that creates nodes should use `from_parent` with keyword arguments, and node subclasses should forward `**kwargs`.
