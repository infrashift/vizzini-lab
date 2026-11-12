---
id: "01a1d174-93d0-7d73-a2d6-f09e1c919f41"
title: "API v1 Route Conventions and GitHub Compatibility"
type: "Guideline"
tags:
  - "api"
  - "compatibility"
  - "backend"
  - "review"
created: "2026-11-12T14:30:40-06:00"
timestamp: "2026-11-12T14:30:40-06:00"
description: "Rules for adding or changing API v1 routes: follow the GitHub API shape, define request/response structs in modules/structs, document every result in swagger, and use the prescribed HTTP methods, status codes and pagination."
x:
  paths: ["routers/api/v1/**", "modules/structs/**"]
  source: ["docs/guideline-backend.md"]
---

# API v1 Route Conventions and GitHub Compatibility

Gitea's REST API v1 is documented by swagger and is modelled on the GitHub REST API. The backend guideline states these rules for anyone adding or maintaining API routes.

## GitHub compatibility

- Use the same endpoints and fields as the GitHub API "as far as possible, unless there are good reasons to deviate".
- If Gitea offers functionality GitHub does not, a new endpoint may be created.
- If Gitea returns information GitHub does not, add a new field that does not collide with any GitHub field.
- Updating an existing API "should not remove existing fields unless there is a really good reason to do so". The same applies to status responses. If a problem is noticed, the guideline suggests leaving a code comment for a future API v2 refactor (API v2 is not currently planned) rather than breaking v1.

## Types and swagger documentation

- All expected results of a route (errors, success, fail messages) must be documented in its swagger comments.
- Every JSON input type must be a struct in `modules/structs/` and be referenced in `routers/api/v1/swagger/options.go`.
- Every JSON response must be a struct in `modules/structs/` and be referenced in its category file under `routers/api/v1/swagger/`.

A reviewer should flag ad-hoc maps or inline types used as API input/output, and swagger annotations that omit possible error responses.

## HTTP methods and status codes

- **GET** returns the requested object(s) with **200 OK**.
- **POST** creates a new object and returns **201 Created** with the created object.
- **PUT** adds/assigns an existing object (e.g. a user to a team) and returns **204 No Content** with no body.
- **PATCH** edits an existing object and returns the changed object with **200 OK**.
- **DELETE** returns **204 No Content** with no body.

## Route requirements

- For endpoints that change or edit an object, all parameters must be optional except those that identify the object.
- Endpoints returning lists must support pagination with the `page` and `limit` query options, and must set the `X-Total-Count` header via `SetTotalCountHeader`.

Changes to existing API output that are incompatible for current users count as breaking changes; see the "Breaking Changes and Backward Compatibility" concept.
