---
id: "01a1d175-7dd3-74b1-9765-a2527676cda1"
title: "Actions Token Permission Clamping"
type: "Guideline"
tags:
  - "security"
  - "actions"
  - "permissions"
  - "design"
created: "2026-11-12T14:31:40-06:00"
timestamp: "2026-11-12T14:31:40-06:00"
description: "Design rules for GITEA_TOKEN permissions in Gitea Actions: workflow requests are always clamped by repository and owner ceilings, fork PRs are restricted, and cross-repo access to private repositories is opt-in and read-only."
x:
  paths: ["services/actions/**", "models/actions/**", "models/perm/access/**", "web_src/js/features/common-actions-permissions.ts", "templates/shared/actions/**"]
  source: ["services/actions/token_permission_design.md"]
---

# Actions Token Permission Clamping

The Actions token permission design document describes a **strict clamping mechanism** for the automatic per-job `GITEA_TOKEN`. Its stated purpose is that "workflows cannot bypass organizational or repository-level security restrictions". Changes in this area should preserve these invariants.

## Evaluation order

1. **Base permissions from the workflow.** Use the job's `permissions:` block, else the inherited top-level block. If the block is invalid or unparseable, or none is defined, fall back to the repository's default `TokenPermissionMode` (Permissive grants `write` to most scopes; Restricted grants `read` or none).
2. **Repository clamping.** Base permissions are clamped by the repository's `MaxTokenPermissions`. A workflow asking for `Issues: write` under a repository ceiling of `Issues: read` gets `read`.
3. **Owner clamping.** The organization or user `MaxTokenPermissions` (in `UserActionsConfig`) cascades down. A repository cannot exceed the owner's limits unless it explicitly enables `OverrideOwnerConfig`.

A workflow may request more than the default mode, but never more than the ceiling.

## Scope parsing

`contents` maps to both `Code` and `Releases`. When a workflow specifies both `contents` and a granular scope such as `code`, the granular scope takes absolute priority. An empty mapping, `permissions: {}`, means revoke everything: every scope becomes `none`. The `Packages` scope is accepted in workflow blocks but hidden from the settings UI.

## Fork pull requests

Workflows triggered by pull requests from forks always run in `Restricted` mode: base permissions on the current repository are downgraded to `read` or `none`, so untrusted code cannot modify the repository. Cross-repository access to other private repositories is denied for fork PRs regardless of configuration.

## Cross-repository access

By default a token can access its own repository plus any truly public repository read-only. Owners can list `AllowedCrossRepoIDs` to grant **read-only** access to other private or internal repositories they own. An empty list means no such access, which the document calls the default "for enhanced security". Jobs can always narrow access further with explicit permissions.

## Packages

Packages belong to an owner, not a repository, so the document says the packages permission "should be designed separately". It sketches, as a possible approach rather than a settled design, an owner-level packages permission that repository-level settings are clamped by.

## Review checklist

Any change that lets a requested permission exceed a ceiling, grants write access in fork PRs, or treats an empty allow-list as permissive contradicts this design.
