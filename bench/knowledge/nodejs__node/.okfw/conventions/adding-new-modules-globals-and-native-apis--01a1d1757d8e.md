---
id: "01a1d175-7d8e-72c4-9664-889ea58a6e40"
title: "Adding New Modules, Globals, and Native APIs"
type: "Guideline"
tags:
  - "api"
  - "modules"
  - "globals"
  - "node-api"
  - "experimental"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "New core modules, global-scope APIs and Node-API additions have stricter labeling, flagging and review requirements than ordinary changes."
x:
  paths: ["lib/*.js", "lib/internal/bootstrap/**", "src/node_api.h", "src/js_native_api.h", "src/node_api_types.h", "src/js_native_api_types.h"]
  source: ["doc/contributing/collaborator-guide.md", "doc/contributing/erm-guidelines.md", "doc/contributing/using-symbols.md"]
---

# Adding New Modules, Globals, and Native APIs

Additions to Node.js's surface area are hard to undo, so the collaborator guide sets specific rules a reviewer should check.

**New core modules**

- Must only be added with the `node:` prefix, as `semver-minor`.
- A sub-module of an existing module (e.g. a promises variant) may be made available without the prefix only behind a runtime flag or as `semver-major`.
- Allow at least one week for review and land only after sign-off from at least two TSC voting members.
- Land with Stability Index "Experimental", and stay Experimental until a semver-major release. The author takes ownership of the experiment: promote or remove it in a timely way, and help assess and patch security issues.

**New APIs on the global scope**

New globals, new interfaces on `globalThis`, or new properties on existing global interfaces can break feature and environment detection. Exposing them unconditionally (no CLI flag) must be labeled `semver-major` (waivable only via TSC consensus). The recommended path is to start behind `--experimental-<feature-name>` and, once feature-complete, enable by default with a `--no-experimental-<feature-name>` opt-out.

**Node-API**

Node-API is ABI-stable and guaranteed for future versions; additions call for unusual care and scrutiny. Any change adding to `node_api.h`, `js_native_api.h`, `node_api_types.h` or `js_native_api_types.h` should follow the dedicated Node-API addition guide.

**Shape of new APIs**

- Do not make a return value polymorphic based on an option (for example, returning a disposable object only when a flag is passed); add a new API variant instead.
- Customization hooks meant for developers use global symbols prefixed `nodejs.`.
- Documented disposable objects must say they are disposable and how to dispose of them.

Changing an existing API's return type to support a new feature is likely breaking; see the breaking-change and deprecation rules in the related concept on API compatibility.
