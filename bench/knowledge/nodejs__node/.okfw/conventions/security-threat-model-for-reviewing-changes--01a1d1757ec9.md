---
id: "01a1d175-7ec9-72d7-9fdc-c4d86a19fcf5"
title: "Security Threat Model for Reviewing Changes"
type: "Guideline"
tags:
  - "security"
  - "threat-model"
  - "network"
  - "parsing"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "What Node.js trusts and does not trust, used to judge whether a change opens a vulnerability."
x:
  paths: ["lib/**/*.js", "src/**", "deps/llhttp/**"]
  source: ["SECURITY.md", "doc/contributing/security-model-strategy.md", "doc/contributing/primordials.md", "doc/contributing/collaborator-guide.md"]
---

# Security Threat Model for Reviewing Changes

Node.js does not provide a sandbox: the JavaScript and native code it runs are trusted not to be malicious. The threat model in `SECURITY.md` decides which bugs count as vulnerabilities, which tells a reviewer where extra scrutiny is needed.

**Untrusted inputs (code handling these needs care)**

- Data from the remote end of inbound connections that Node.js parses or validates before handing to the application, such as HTTP server APIs.
- Data from outbound connections (HTTP client, DNS) that Node.js transforms, except payload length, which applications are trusted to manage.
- Consumers of data protected by Node.js APIs (e.g. holders of encrypted data).
- File contents and other I/O read or written through Node.js APIs.

If such data can trigger actions beyond those documented, such as polluting globals, causing an unrecoverable crash, or other unexpected side effects, it is likely a vulnerability. Untrusted input must never lead to arbitrary code execution when the application code is correct. Bugs in HTTP header parsing that allow request smuggling, flawed certificate SAN validation, and crypto bugs that reveal plaintext without the key are listed examples.

**Availability**

Unbounded performance degradation of the runtime counts as a vulnerability. DoS reports must meet strict criteria, such as a stable documented API used correctly, an untrusted source, and asymmetric resource consumption.

**Trusted (not vulnerabilities on their own)**

The OS and its configuration, the developers, the code being run (including npm dependencies and native code), inputs that application code passes to APIs (e.g. `JSON.parse()` input), inspector connections, the file system when requiring modules, and the inputs to `path.join()`/`path.normalize()`. Prototype pollution by the application, unhandled `'error'` events, and exceptions thrown by application callbacks are listed as non-vulnerabilities. Defense-in-depth fixes are not treated as vulnerabilities.

**Other review points**

- Loading configuration files or running code by default without documenting it is a vulnerability.
- The project still works to avoid APIs that make it easy for applications to misuse them in vulnerable ways.
- Experimental features may have security issues, and their authors are expected to help assess and patch them.
- The primordials guidance exists so core behavior cannot be altered by user-mutated built-ins.
