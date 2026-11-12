---
id: "01a1d176-5016-788e-8503-73838c8b7705"
title: "Optional features and fallback behaviour"
type: "Guideline"
tags:
  - "backends"
  - "features"
  - "contracts"
  - "performance"
created: "2026-11-12T14:32:34-06:00"
timestamp: "2026-11-12T14:32:34-06:00"
description: "What each optional fs.Features capability means and how rclone falls back when a backend lacks it."
x:
  paths: ["fs/features.go", "fs/types.go", "fs/operations/**", "fs/sync/**", "backend/**"]
  source: ["docs/content/overview.md", "docs/content/docs.md", "AGENTS.md", "CONTRIBUTING.md"]
---

# Optional features and fallback behaviour

All remotes support a base command set. Everything else is an optional feature that a backend declares through `fs.Features`, where a nil function pointer means "not supported" (AGENTS.md). `docs/content/overview.md` defines what each feature means and what rclone does without it. Rclone itself provides these fallbacks when a feature is missing.

## Feature semantics and fallbacks (overview.md)

- **Purge** deletes a directory faster than deleting each file.
- **Copy** is a server-side copy within the same remote. Without it, a copy downloads the file and uploads it again.
- **Move** is a server-side move or rename. Without it, rclone uses Copy and then delete. Without Copy as well, it downloads and re-uploads.
- **DirMove** moves a whole directory. Without it, rclone calls Move on each file, with the fallbacks above.
- **CleanUp** empties the trash. Without it, `rclone cleanup` returns an error.
- **ListR** is a fast recursive listing and is what makes `--fast-list` work.
- **StreamUpload** uploads without knowing the size in advance, for example in `rclone rcat`, so the file does not have to be spooled to disk first.
- **MultithreadUpload** sends chunks in parallel and enables multi-thread copies.
- **About** reports quota. Without it, `rclone about` errors and mount cannot report free space.
- **EmptyDir** means the remote can hold empty directories. Most bucket-based remotes cannot.

Server-side copies are only attempted when the remote names are the same, unless `--server-side-across-configs` is set. That flag is off by default because rclone cannot easily tell whether a server-side copy will work between two configurations (docs.md).

## Modification times

overview.md separates backends that cannot store the source modtime, backends that store it but cannot change it without re-uploading (no `SetModTime`), and backends that support modtime-only updates. `copy` and `sync` check for `SetModTime` support and re-upload when they need to. `touch` on an existing file fails without it, and modtime-only changes in a mount are silently ignored. When a backend cannot store the source modtime, rclone checks only the size by default, or the hash with `--checksum`.

## Hashes

Hashes serve as integrity checks during transfers and in `--checksum` and `check`. Checksums can only be verified between two remotes that support a common hash type.

## Review checklist

- Does a new backend method match its documented feature meaning?
- Does core code handle a nil feature by using the documented fallback rather than failing?
- When ListR is added, have the tests been run with `-fast-list` too (CONTRIBUTING.md)?
