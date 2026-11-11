---
id: "01a1cb22-3889-7604-b838-d3abb064d485"
title: "ADR-0001: No dynamic code execution and no shell command strings"
type: "ADR"
tags:
  - "adr"
  - "security"
  - "execution"
created: "2026-11-11T09:02:59-06:00"
timestamp: "2026-11-11T09:02:59-06:00"
description: "Never eval or construct code from strings, and start child processes with execFile and an argument array, never a shell command string."
x:
  paths: ["src/**/*.ts"]
---

# ADR-0001: No dynamic code execution and no shell command strings

**Status:** Accepted

## Context
The API handles input from customers and webhook senders. Code built from strings and shell commands built by concatenation are the two ways that input could run as code on our hosts.

## Decision
- No `eval`, `new Function`, `vm.runInThisContext`, or `setTimeout`/`setInterval` with a string.
- Child processes start with `execFile`/`spawn` and an **argument array**. `exec`/`execSync` with a command string is forbidden, even when the input "looks safe".
- Formulas and expressions go through a parser for the grammar we support, never through JavaScript.

## Consequences
A reviewer can search for `exec(`, `execSync(` and `eval(`: any hit outside tests is a violation.
