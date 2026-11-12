---
id: "01a1d175-8eb0-7bf2-9f9f-d974b786cb9e"
title: "Imports and Import-Time Settings Access"
type: "Guideline"
tags:
  - "imports"
  - "settings"
  - "architecture"
created: "2026-11-12T14:31:44-06:00"
timestamp: "2026-11-12T14:31:44-06:00"
description: "How Django modules order and write imports, and why they must not read django.conf.settings when the module is imported."
x:
  paths: ["django/**/*.py"]
  source: ["docs/internals/contributing/writing-code/coding-style.txt"]
---

# Imports and Import-Time Settings Access

**Import ordering (enforced by isort)**
- Use these groups, in this order: future, standard library, third-party libraries, other Django components, the local Django component, then try/except imports.
- Within each group, sort lines alphabetically by full module name, and put every `import module` before any `from module import objects`.
- Within a line, sort the imported names alphabetically, with upper-case names before lower-case ones.
- Use absolute imports for other Django components. Use a one-dot relative import (`from .models import LogEntry`) for the local component. Avoid multi-dot relative imports.
- Wrap long imports in parentheses with 4-space continuation indent, a trailing comma after the last name, and the closing parenthesis on its own line.
- Leave one blank line between the imports and module-level code, and two blank lines before the first function or class.
- An import that must stay out of order, for example to avoid a circular import, is marked `# isort:skip`.
- Use convenience imports where they exist, for example `from django.views import View` rather than `from django.views.generic.base import View`.

**No settings access at import time**
In general, modules should not read `django.conf.settings` at the top level, meaning code that runs when the module is imported. `settings` is a `LazyObject` that configures itself the first time any setting is read. A project may call `settings.configure(...)` manually instead of using `DJANGO_SETTINGS_MODULE`, but only if nothing has read a setting before that call.

So a module-level line like `default_foo_view = get_callable(settings.FOO_VIEW)` configures settings as a side effect of importing the module. Third parties then can't import that module before configuring settings themselves. The style guide requires "a level of laziness or indirection" instead, such as `django.utils.functional.LazyObject`, `django.utils.functional.lazy()` or a `lambda`.

A reviewer should flag any new module-level expression that reads `settings.<NAME>` in framework code.
