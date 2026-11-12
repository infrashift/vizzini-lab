---
id: "01a1d176-1ad3-705f-bd30-a81c595163ce"
title: "Plugin Loading, conftest Scope and Assertion Rewriting"
type: "Guideline"
tags:
  - "architecture"
  - "plugins"
  - "config"
  - "assertion-rewriting"
created: "2026-11-12T14:32:20-06:00"
timestamp: "2026-11-12T14:32:20-06:00"
description: "pytest loads builtin, entry-point and conftest plugins in a fixed startup order, scopes conftest hooks per directory, and rewrites asserts only in test modules and registered plugin modules."
x:
  paths: ["src/_pytest/config/**/*.py", "src/_pytest/main.py", "src/_pytest/assertion/**/*.py", "src/_pytest/mark/**/*.py", "src/_pytest/helpconfig.py"]
  source: ["doc/en/how-to/writing_plugins.rst", "doc/en/how-to/writing_hook_functions.rst", "doc/en/deprecations.rst", "testing/plugins_integration/README.rst"]
---

# Plugin Loading, conftest Scope and Assertion Rewriting

Most of pytest is itself a set of plugins, so changes to configuration, collection or assertion code have to respect how plugins are found and loaded.

## Startup order

pytest loads plugins in this order:

1. Scan the command line for `-p no:name` and block that plugin (builtin plugins can be blocked too), before normal option parsing.
2. Load all builtin plugins from `_pytest`.
3. Load plugins named with `-p name`, also before normal option parsing.
4. Load plugins registered through the `pytest11` entry point, unless `PYTEST_DISABLE_PLUGIN_AUTOLOAD` is set.
5. Load plugins listed in the `PYTEST_PLUGINS` environment variable.
6. Load the "initial" `conftest.py` files for the test paths (parents first), recursively loading any `pytest_plugins` they declare.

Some hooks cannot be implemented in non-initial `conftest.py` files because of this order. A change that moves when plugins or conftests are loaded affects which hooks they can use.

## conftest.py and pytest_plugins

- `conftest.py` hooks apply only to tests in that directory and below.
- Declaring `pytest_plugins` in a non-root `conftest.py` is deprecated and warns, because an imported plugin affects the whole tree, not just that directory.
- `pytest_generate_tests` is the one hook also discovered in test modules and classes; other hooks must live in conftest files or plugins.

## Assertion rewriting

- Rewriting happens through an import hook installed early at startup. It rewrites only test modules (matched by `python_files`) and plugin modules (conftest files, `pytest11` entry-point modules, and modules named in `pytest_plugins`), because "we do not want to test different bytecode from what you will run in production".
- Other modules need `pytest.register_assert_rewrite` called before they are imported. If a `pytest_plugins` module was already imported, pytest warns and its asserts are not rewritten.

## Markers and options

- Plugins should register their markers (for example with `config.addinivalue_line("markers", ...)` in `pytest_configure`) so they appear in help and do not cause unknown-mark warnings.
- Plugins add command-line options with `pytest_addoption` and `parser.getgroup(...).addoption(...)`. Another plugin can supply an option default through a `firstresult` hook.

## Review checks

Changes to load order, to which modules get rewritten, or to conftest scoping change behaviour for existing plugins. The project keeps smoke tests in `testing/plugins_integration/` to "gauge if any intentional or unintentional changes in pytest break plugins", and such changes fall under the [Backward Compatibility and Deprecation Policy](./backward-compatibility-and-deprecation-policy--01a1d17619c0.md).
