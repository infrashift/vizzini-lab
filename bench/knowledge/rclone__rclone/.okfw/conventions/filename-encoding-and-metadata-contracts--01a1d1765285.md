---
id: "01a1d176-5285-7596-b49a-6f093e9c9d73"
title: "Filename encoding and metadata contracts"
type: "Guideline"
tags:
  - "backends"
  - "encoding"
  - "metadata"
  - "contracts"
created: "2026-11-12T14:32:34-06:00"
timestamp: "2026-11-12T14:32:34-06:00"
description: "Rules backends follow for restricted characters, invalid UTF-8 and the shared metadata framework."
x:
  paths: ["lib/encoder/**", "fs/metadata.go", "fs/metadata_mapper_code.go", "backend/**"]
  source: ["docs/content/overview.md", "docs/content/docs.md", "CONTRIBUTING.md"]
---

# Filename encoding and metadata contracts

## Restricted filenames

When a backend cannot store some characters in names, rclone replaces them on upload with similar-looking Unicode characters and reverses the change on download and when parsing arguments. This system is called *encoding* (overview.md). Some examples:

- `?` is stored on OneDrive as the fullwidth `？`.
- If a name already contains a replacement character, that character is escaped with `‛` so names stay unambiguous.
- On backends that require valid UTF-8, each invalid byte is written in quoted form. For example, `0xFE` becomes `‛FE`.
- Each backend has its own set of restricted characters, exposed as an `encoding` config option or a `--<backend>-encoding` flag. The default is chosen to preserve as many characters as possible.

CONTRIBUTING.md tells backend authors to use `lib/encoder` so that "we can encode any path name", and to measure what a remote needs with `rclone test info --all --remote-encoding None`. A backend that passes raw names to the provider API without going through its encoder works against this contract.

## Case and duplicates

Remotes differ in case sensitivity, and some allow duplicate names. Syncing between a case-insensitive and a case-sensitive remote can make a sync that never completes. Duplicates "confuse rclone greatly". These are documented properties of each backend, not things core code may assume away.

## Metadata framework

`docs/content/docs.md` describes the contract:

- Metadata is read from an object and written to it **when, and only when, the object is uploaded**. Sync of metadata is one-time: if only the metadata changes on the source, it is not synced again.
- Metadata is a dictionary of string keys to string values. Keys must be lower case and use `a-z`, `0-9`, `.`, `-` and `_`. Length limits depend on the backend.
- *System* metadata is understood by the backend, for example `uid` on local. *User* metadata is arbitrary. A key can change from one kind to the other as objects move between backends.
- Standard system keys are `mode`, `uid`, `gid`, `rdev`, `atime`, `mtime`, `btime`, `utime`, `cache-control`, `content-disposition`, `content-encoding`, `content-language` and `content-type`. When they are supplied, `mtime` and `content-type` take precedence over the source object's modtime and Content-Type.
- Hashes are not part of system metadata.
- The goals are, in order, to "preserve metadata if at all possible" (lossless round trips such as S3 to local to S3) and then to "interpret metadata if at all possible".
- `--metadata-set` and `--metadata-mapper` apply to server-side Move and Copy, but not to DirMove.
- Some backends limit metadata size, and rclone gives an error on upload when that limit is exceeded.
