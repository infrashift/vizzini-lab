---
id: "01a1d176-1a20-7bab-ad35-7b58733195e0"
title: "Hook Specification and Implementation Rules"
type: "Guideline"
tags:
  - "plugins"
  - "hooks"
  - "pluggy"
  - "architecture"
created: "2026-11-12T14:32:20-06:00"
timestamp: "2026-11-12T14:32:20-06:00"
description: "pytest is built from pluggy hooks with pytest_-prefixed names, validated argument names, keyword-only calls and the hookimpl decorators, and most hooks must not raise."
x:
  paths: ["src/_pytest/hookspec.py", "src/_pytest/**/*.py", "src/_pytest/config/__init__.py"]
  source: ["doc/en/how-to/writing_hook_functions.rst", "doc/en/how-to/writing_plugins.rst", "doc/en/deprecations.rst", "doc/en/reference/reference.rst"]
---

# Hook Specification and Implementation Rules

"pytest implements all aspects of configuration, collection, running and reporting by calling well specified hooks" of builtin plugins (in `_pytest`), external plugins and `conftest.py` files. Each hook call is a 1:N call over all registered implementations. Hook specifications live in `_pytest/hookspec.py`.

## Naming and signatures

- All specifications and implementations use the `pytest_` prefix; hooks without it are not recognized.
- At registration pytest checks that an implementation's argument names match the specification and "bail[s] out if not". An implementation may list only a subset of the arguments.
- Because of this pruning, adding a **new named parameter** to an existing hook does not break existing implementations. This is "one of the reasons for the general long-lived compatibility of pytest plugins". Removing or renaming a parameter does break them.
- Hooks are called with keyword arguments only, through `config.hook` (or `pluginmanager.hook`).
- New hooks are declared as do-nothing functions whose docstring says when the hook is called and what it returns, and are registered with `pytest_addhooks` and `pluginmanager.add_hookspecs`.

## Behaviour rules

- "Hook functions other than `pytest_runtest_*` are not allowed to raise exceptions. Doing so will break the pytest run."
- `firstresult=True` specs stop at the first non-None result; the remaining implementations are not called. Use it when only one plugin should provide the value.
- Wrappers use `@pytest.hookimpl(wrapper=True)`: a generator that yields exactly once and must return a result or raise. The yield re-raises any exception from inner implementations, so cleanup belongs in `try`/`finally`. Modifying a mutable result in place is allowed but "probably better to avoid".
- Ordering is controlled with `tryfirst` / `trylast`. Configuring hooks with `pytest.mark.tryfirst` or function attributes is deprecated; use `pytest.hookimpl` and `pytest.hookspec`.
- Some hooks cannot be implemented in non-initial `conftest.py` files; each hook's documentation says so.
- Data shared between hook implementations on items or config should use `item.stash` / `config.stash` with module-level `pytest.StashKey[T]()` keys, not private attributes set on the object, which type checkers reject and which can clash with other plugins.
- The `pytest_warning_captured` hook was removed because its `item` parameter "cannot be serialized by `pytest-xdist`"; its replacement, `pytest_warning_recorded`, takes a `nodeid` instead. Hook arguments that must cross process boundaries are a known concern.

## Review checks

Look for new hook parameters (fine) versus removed or renamed ones (a breaking change), raising from non-runtest hooks, old-style mark-based hook configuration, and wrappers that swallow the result.
