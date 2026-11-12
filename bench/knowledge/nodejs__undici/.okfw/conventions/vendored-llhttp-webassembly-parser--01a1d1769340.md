---
id: "01a1d176-9340-72f4-b8fd-f203910b9db8"
title: "Vendored llhttp WebAssembly parser"
type: "Guideline"
tags:
  - "architecture"
  - "parser"
  - "build"
created: "2026-11-12T14:32:51-06:00"
timestamp: "2026-11-12T14:32:51-06:00"
description: "undici's HTTP/1.1 parser is a vendored WebAssembly build of llhttp, updated by a documented copy-and-rebuild procedure rather than by editing the generated files."
x:
  paths: ["lib/llhttp/**", "deps/llhttp/**", "build/wasm.js"]
  source: ["CONTRIBUTING.md", "SECURITY.md"]
---

# Vendored llhttp WebAssembly parser

## What lives where

"The HTTP parser used by `undici` is a WebAssembly build of `llhttp`." Instead of consuming a prebuilt module, the project embeds llhttp's C sources and compiles the WebAssembly module itself:

- `deps/llhttp/include/` holds the C header files.
- `deps/llhttp/src/` holds the C source files needed to compile the module.
- `lib/llhttp/` holds "the `.js` transpiled assets required to implement a parser".
- `build/wasm.js` is the build script. It also accepts `EXTERNAL_PATH`, `WASM_CC`, `WASM_CFLAGS`, `WASM_LDFLAGS`, `WASM_LDLIBS` and `WASM_OPT` for distro and externally shared builds.

## How an update is supposed to look

`CONTRIBUTING.md` documents the update procedure:

1. Clone llhttp and check out a release tag.
2. Install its dependencies and run its `npm run build:wasm` (requires Docker).
3. Copy `build/wasm/*.js`, `*.js.map` and `*.d.ts` into `lib/llhttp/`, and the listed C sources and headers into `deps/llhttp/src` and `deps/llhttp/include`.
4. Run `npm run build:wasm` in undici (also Docker-based).
5. Commit all the updated files in `lib/llhttp`.

For review, this means a parser update should come as a coherent set: C sources, headers and generated JS/type/wasm artifacts that all correspond to one llhttp release and were produced by the build, with the whole `lib/llhttp` change committed together. The docs describe these files as copied and generated output; they do not describe hand-editing them.

## Why it matters

The parser handles response status lines, headers and transfer encoding, which `SECURITY.md` lists as data undici does not trust. Parsing bugs that enable response smuggling or desynchronization (CWE-444) are treated as vulnerabilities, and `HTTPParserError` is the error raised for malformed responses. See the "Security threat model" concept.

The docs say little else about the parser's internals; beyond the update procedure above, there is no documented guidance on modifying it.
