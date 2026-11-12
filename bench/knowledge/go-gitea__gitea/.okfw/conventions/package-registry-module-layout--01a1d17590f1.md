---
id: "01a1d175-90f1-7a0d-bb82-960bfb74c478"
title: "Package Registry Module Layout"
type: "Guideline"
tags:
  - "architecture"
  - "packages"
  - "module-boundaries"
created: "2026-11-12T14:31:45-06:00"
timestamp: "2026-11-12T14:31:45-06:00"
description: "How package registry code is split across models, modules, services and routers, the shared Package/Version/File/Blob model, and which service helper an upload path should call."
x:
  paths: ["routers/api/packages/**", "models/packages/**", "modules/packages/**", "services/packages/**"]
  source: ["routers/api/packages/README.md", "modules/git/README.md"]
---

# Package Registry Module Layout

The package registry README describes a fixed split of responsibilities so that functionality can be reused across registry types. A change that puts code in the wrong layer goes against this layout.

## Layers

| Location | Responsibility |
| - | - |
| `models/packages` | Common methods and models used by all registry types |
| `models/packages/<type>` | Type-specific model methods; "there should be no need to use type specific models" |
| `modules/packages` | Common methods and types shared by several registry types |
| `modules/packages/<type>` | Type-specific logic, such as metadata extraction from package files |
| `routers/api/packages` | Route definitions for all registry types |
| `routers/api/packages/<type>` | Route implementation for one registry type |
| `services/packages` | Helpers used by routers for common tasks such as package creation and deletion |
| `services/packages/<type>` | Type-specific methods used by `routers` and `services` |

## Shared model

Every registry type uses the same underlying models:

```
Package <1---*> PackageVersion <1---*> PackageFile <*---1> PackageBlob
```

`Package` holds values fixed across versions (such as the name), `PackageVersion` holds version metadata, `PackageFile` describes a file, and `PackageBlob` holds content that may be shared by several files. `PackageProperty` attaches extra properties to a package, version or file, for example when metadata is needed for routing.

## Adding or changing a registry type

- Look at existing implementations first; most types offer metadata, upload and download endpoints.
- The upload endpoint is "often the heavy part" because it must validate the uploaded blob, extract metadata and create models. Validation and metadata extraction belong in `modules/packages/<type>`.
- Once the upload is valid, store it through `services/packages`, choosing the helper that matches the registry's rules on multiple files per version:
  - `CreatePackageAndAddFile`: errors if the package version already exists.
  - `CreatePackageOrAddFileToExisting`: errors if the file already exists.
  - `AddFileToExistingPackage`: errors if the version does not exist or the file already exists.
- `services/packages` also provides helpers for downloading a file and removing a package version. Metadata endpoints have no shared helpers because they are very type-specific.

A reviewer should check that a new registry does not reimplement storage or model creation that `services/packages` already provides, and that the chosen helper matches the registry's duplicate-handling semantics.

## Other module notes

The docs say little else about module boundaries. The `modules/git` README notes only that this module, which accesses Git through shell commands, was merged in from a separate repository and is now part of the main repository.
