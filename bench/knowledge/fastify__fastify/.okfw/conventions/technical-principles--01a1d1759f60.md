---
id: "01a1d175-9f60-7e3b-a2ce-ab9752c1775e"
title: "Technical Principles"
type: "Guideline"
tags:
  - "fastify"
  - "architecture"
  - "principles"
  - "performance"
created: "2026-11-12T14:31:49-06:00"
timestamp: "2026-11-12T14:31:49-06:00"
description: "The ten technical principles that guide every Fastify design decision, and what each one means for a code change under review."
x:
  paths: ["lib/**", "fastify.js"]
  source: ["docs/Reference/Principles.md", "docs/Guides/Write-Plugin.md"]
---

# Technical Principles

`docs/Reference/Principles.md` states that "every decision in the Fastify framework and its official plugins" is guided by ten principles. They are the yardstick for judging whether a change fits.

1. **"Zero" overhead in production.** Features are implemented "with minimal overhead" using fast algorithms, data structures, and JavaScript-specific features. A change that adds work to the hot request path needs a justification; the docs admit this principle can conflict with developer experience, which "usually incur[s] some overhead".
2. **"Good" developer experience** at that performance point. Concretely: "binary addons are forbidden because most JavaScript developers do not have access to a compiler." A new native dependency is out.
3. **Works for small and big projects alike**, with features to structure growing codebases.
4. **Easy to migrate to microservices or serverless and back.** "Route deployment should not matter."
5. **Security and data validation.** The framework is "the first point of contact with untrusted data and must act as the first line of defense". See "Untrusted Input, Validation and Parsing Security".
6. **If something could be a plugin, it likely should be.** Core provides hooks and options instead of catering to every use case, to keep the codebase maintainable. A feature proposal for core should be asked whether it could live in a plugin.
7. **Easily testable.** Testing applications is a first-class concern (see "Testing Expectations").
8. **Do not monkeypatch core.** "Monkeypatching Node.js APIs or installing globals that alter the runtime" is not done. Reject changes that patch Node built-ins or add globals.
9. **Semantic versioning and Long Term Support.**
10. **Specification adherence.** "In doubt, we chose the strict behavior as defined by the relevant Specifications." When HTTP or other specs are ambiguous, prefer the strict reading.

The plugin-writing guide repeats the core trio for plugin authors: "performance, low overhead, and providing a good experience to our users".
