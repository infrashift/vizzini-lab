---
id: "01a1d175-9fcd-76eb-b098-3b036cd38f23"
title: "Security Rules for Framework Code"
type: "Guideline"
tags:
  - "security"
  - "sql-injection"
  - "xss"
  - "csrf"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "Security rules from Django's docs that apply when reviewing framework code: parameterized SQL, careful marking of strings as safe, CSRF exemptions, input size assumptions, and severity levels."
x:
  paths: ["django/db/**/*.py", "django/template/**", "django/templatetags/**", "django/utils/html.py", "django/utils/safestring.py", "django/middleware/**", "django/contrib/auth/**"]
  source: ["docs/topics/security.txt", "docs/ref/models/expressions.txt", "docs/internals/security.txt", "docs/misc/api-stability.txt", "docs/misc/design-philosophies.txt"]
---

# Security Rules for Framework Code

Django's security documentation mostly covers reporting and user guidance. The points below are the ones that apply directly to reviewing framework code.

**SQL injection**
- QuerySets are protected because "a query's SQL code is defined separately from the query's parameters". The database driver escapes the parameters. Any change to SQL generation must keep user-controllable values in the parameters and never interpolate them into the SQL string.
- In `Func` expressions, keyword arguments to `__init__()` (`**extra`) and to `as_sql()` (`**extra_context`) are interpolated into the SQL string, not passed as parameters, so they must never contain untrusted input. Pass values as positional expressions so they become query parameters.
- Raw SQL, `QuerySet.extra()` and `RawSQL` hand full control of the query to the developer. They "should be used sparingly", and every user-controllable parameter must be escaped.

**XSS and the template layer**
- Template auto-escaping protects against most XSS but not all of it. For example, it doesn't protect an unquoted attribute value like `<style class={{ var }}>`.
- Take particular care with `is_safe` in custom tags and filters, the `safe` filter, `mark_safe`, and code that turns off autoescaping.
- Output formats other than HTML may need entirely different escaping.
- Per the design philosophies, the template system must not allow arbitrary Python code or "commands that delete database records".

**CSRF and clickjacking**
- Marking views `csrf_exempt` needs great care and should be done only when "absolutely necessary".
- `XFrameOptionsMiddleware` can be disabled per view.

**Input handling and resource assumptions**
- Untrusted data must be validated before use, normally with forms. Headers such as `Remote-User` and `X-Forwarded-*` must be sanitized by the web server or proxy.
- The security team assumes production limits: request headers and URLs under 8K bytes, request bodies under 2.5 MB (`DATA_UPLOAD_MAX_MEMORY_SIZE`), and under 100 KB of text through template language filters. Django makes no guarantee that template text filters perform well on crafted, very large inputs.

**Compatibility and severity**
- Security fixes may break backwards compatibility: "security trumps the compatibility guarantee".
- Severity levels: High is remote code execution and SQL injection. Moderate is XSS, CSRF and broken authentication. Low is denial of service, sensitive data exposure, broken session management, unvalidated redirects, and issues that need an uncommon configuration.
