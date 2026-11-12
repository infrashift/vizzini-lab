---
id: "01a1d175-9fbe-7be0-82aa-c33716ec7fc8"
title: "Decorators and Object Shape"
type: "Guideline"
tags:
  - "fastify"
  - "decorators"
  - "performance"
  - "security"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "Rules for decorate, decorateRequest and decorateReply: declare shape up front, never share reference types across requests, and keep decoration synchronous."
x:
  paths: ["lib/decorate.js", "lib/request.js", "lib/reply.js", "types/instance.d.ts", "types/request.d.ts", "types/reply.d.ts"]
  source: ["docs/Reference/Decorators.md", "docs/Reference/Errors.md"]
---

# Decorators and Object Shape

The decorators API (`decorate`, `decorateRequest`, `decorateReply`) attaches properties to the server, request, and reply objects. The docs give it both a performance and a security role.

## Declare shape before use

- Decorating lets the JavaScript engine optimize "by defining the shape of all such object instances before they are instantiated and used."
- Adding properties to `request` or `reply` inside a hook without a prior decorator (`req.user = ...` in `preHandler`) is labelled a bad example: it "mutates the request object after instantiation, causing the JavaScript engine to deoptimize access."
- "Keep the initial shape of a decorated field close to its future dynamic value": initialize with `''` for strings and `null` for objects or functions.

## No shared reference types on request or reply

- `decorateRequest` and `decorateReply` with an object or array value is blocked (`FST_ERR_DEC_REFERENCE_TYPE`). The reference would be shared by all requests, so "any mutation will impact all requests, potentially creating security vulnerabilities or memory leaks."
- The correct patterns are: declare the decorator, then assign a fresh value per request in an `onRequest` hook; or use a getter with a separate holder decorator so each request gets its own object.

## Synchronous only

- The API "is *synchronous*. Defining a decoration asynchronously could result in the Fastify instance booting before the decoration completes." Asynchronous setup belongs in a plugin registered with `fastify-plugin`.
- Decorating after the server has started is an error (`FST_ERR_DEC_AFTER_START`), and re-declaring an existing name is `FST_ERR_DEC_ALREADY_PRESENT`.

## Dependencies and `this`

- The optional `dependencies` list is checked before the instance boots; an unmet dependency throws.
- `getDecorator` throws `FST_ERR_DEC_UNDECLARED` for unknown names and is meant for validating dependencies at boot.
- Functions used as request or reply decorators must not be arrow functions: "Using an arrow function will break the binding of `this`" to the Request or Reply instance.

Decorators follow encapsulation: a decorator added inside a plugin is visible only in that context unless the plugin is wrapped with `fastify-plugin`.
