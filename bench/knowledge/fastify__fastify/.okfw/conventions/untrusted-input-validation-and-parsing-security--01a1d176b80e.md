---
id: "01a1d176-b80e-79a2-b003-21ed032dcf60"
title: "Untrusted Input, Validation and Parsing Security"
type: "Guideline"
tags:
  - "fastify"
  - "security"
  - "validation"
  - "parsing"
  - "prototype-poisoning"
created: "2026-11-12T14:33:00-06:00"
timestamp: "2026-11-12T14:33:00-06:00"
description: "Fastify's threat model and the security rules for body parsing, JSON handling, schema validation and serialization that a change to the request path must preserve."
x:
  paths: ["lib/content-type-parser.js", "lib/content-type.js", "lib/validation.js", "lib/schemas.js", "lib/schema-controller.js", "lib/request.js", "lib/route.js", "lib/server.js", "build/build-validation.js"]
  source: ["SECURITY.md", "docs/Reference/Principles.md", "docs/Reference/Validation-and-Serialization.md", "docs/Reference/Server.md", "docs/Reference/ContentTypeParser.md", "docs/Guides/Prototype-Poisoning.md", "docs/Reference/Decorators.md", "docs/Reference/Routes.md"]
---

# Untrusted Input, Validation and Parsing Security

## Threat model

`SECURITY.md` draws the line:

- **Trusted:** application code (plugins, handlers, hooks, schemas), configuration, and the runtime.
- **Untrusted:** "All network input (HTTP headers, body, query strings, URL parameters)." Node.js is assumed to run with `insecureHTTPParser: false`.
- Core vulnerabilities include parsing flaws that bypass validation or security controls, DoS through malformed input to core, and bypasses of built-in protections such as prototype poisoning and schema validation.

A change to parsing, routing, or validation in core must not open any of these paths. Principle 5 says the framework "must act as the first line of defense".

## JSON and prototype poisoning

- Body JSON is parsed with `secure-json-parse`. `onProtoPoisoning` and `onConstructorPoisoning` default to `'error'` for objects containing `__proto__` or `constructor` (alternatives: `'remove'`, `'ignore'`).
- The prototype-poisoning guide explains why: an object from `JSON.parse()` is safe on its own, but a shallow copy such as `Object.assign()` turns `__proto__` into a real prototype, so data can slip past validators that check only own properties. The mitigation wraps the fast built-in parser instead of replacing it, because extra parsing cost is itself a DoS risk.

## Limits and parsers

- `bodyLimit` (default 1 MiB) is enforced by the default body reader; with a `preParsing` hook it applies to the decoded stream.
- Validation runs only for `application/json` unless the body schema has a `content` map. A parser registered with a regex can accept content types the `content` map does not cover; those bodies are parsed but **not validated**. The project treats this as an application configuration concern.

## Schemas

- "Treat schema definitions as application code." Ajv and fast-json-stringify compile with `new Function()`, "which is unsafe with user-provided schemas."
- Ajv `$async` validation "should not be used for initial validation"; database access during validation may lead to DoS. Use `preHandler` for async work.
- Validation error details are returned to the client by default, which may expose schema internals.
- Ajv's `allErrors` option is flagged in the docs as a known security risk.

## Other documented risks

- Request or reply decorators with reference types would share state across requests ("security vulnerabilities or memory leaks"); Fastify blocks this.
- Version-constrained routes should set a `Vary` header to prevent cache poisoning.
