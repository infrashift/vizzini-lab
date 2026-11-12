---
id: "01a1d175-8edf-7f06-b8d2-fed747d0811a"
title: "Template, View and Model Code Style"
type: "Guideline"
tags:
  - "style"
  - "templates"
  - "models"
  - "views"
created: "2026-11-12T14:31:44-06:00"
timestamp: "2026-11-12T14:31:44-06:00"
description: "Django's style rules for template markup, view function signatures, and the layout of model classes."
x:
  paths: ["django/**/templates/**", "django/contrib/**/*.py", "django/views/**", "tests/**/models.py"]
  source: ["docs/internals/contributing/writing-code/coding-style.txt", "docs/misc/design-philosophies.txt"]
---

# Template, View and Model Code Style

The coding style guide gives specific rules for Django template code, views and models. Use them when reviewing templates shipped with Django (for example the admin's templates) and models or views in framework code and tests.

**Templates**
- `{% extends %}` is the first non-comment line. A `{% load %}` must not come before it.
- Put exactly one space inside `{{ ... }}` and `{% ... %}`: write `{{ user }}`, not `{{user}}`.
- In `{% load ... %}`, list libraries alphabetically.
- When `{% endblock %}` is not on the same line as its `{% block %}`, it repeats the block name (`{% endblock header %}`).
- Inside braces, separate tokens with single spaces. The exceptions are `.` for attribute access and `|` for filters, which take no spaces (`{% if user.name|lower == "admin" %}`).
- In a template that uses `{% extends %}`, don't indent top-level `{% block %}` tags.
- Per the design philosophies, templates handle presentation and presentation-related logic only. The template language deliberately avoids advanced logic and must not allow arbitrary Python code.

**Views**
- The first parameter of a view function is named `request` (not `req`).
- Per the design philosophies, views receive the request object directly rather than reading it from a global. A view shouldn't care which template system is used, and GET and POST are kept distinct.

**Models**
- Field names are lowercase with underscores: `first_name`, not `FirstName` or `Last_Name`.
- `class Meta` comes after the fields, separated from them by one blank line.
- Order the class body as follows (not every item is required): database fields, custom manager attributes, `class Meta`, `__str__()` and other magic methods, `save()`, `get_absolute_url()`, then any custom methods.
- When a field defines `choices`, define each choice as an all-uppercase class attribute and the choices as a mapping, or use the enumeration types such as `models.TextChoices`.
- Per the design philosophies, behavior comes from keyword arguments and the field type, never from a field's name.
