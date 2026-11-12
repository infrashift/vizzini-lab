# conventions

<!-- okfw:generated — maintained by okfw; edits here are overwritten -->

## Concepts

* [API v1 Route Conventions and GitHub Compatibility](api-v1-route-conventions-and-github-compatibility--01a1d17493d0.md) - Rules for adding or changing API v1 routes: follow the GitHub API shape, define request/response structs in modules/structs, document every result in swagger, and use the prescribed HTTP methods, status codes and pagination.
* [Actions Token Permission Clamping](actions-token-permission-clamping--01a1d1757dd3.md) - Design rules for GITEA_TOKEN permissions in Gitea Actions: workflow requests are always clamped by repository and owner ceilings, fork PRs are restricted, and cross-repo access to private repositories is opt-in and read-only.
* [Breaking Changes and Backward Compatibility](breaking-changes-and-backward-compatibility--01a1d17493f2.md) - What the project counts as a breaking change (API output, admin settings, defaults, manual restore steps), what a breaking PR must include, and the stated rule for partial table migrations.
* [Code Style, Headers, Comments and PR Scope](code-style-headers-comments-and-pr-scope--01a1d1757d51.md) - Project-stated style rules a reviewer can check on any change: make fmt and lint, the MIT copyright header on new files, comment preservation and style, Conventional Commits titles, and small single-purpose PRs.
* [Dependency Change Policy](dependency-change-policy--01a1d1747fe5.md) - go.mod/go.sum and frontend package manifests may change only when tied to the PR's purpose or in dependency-only PRs, and every update must be justified and point at a real upstream commit or version.
* [Frontend Conventions](frontend-conventions--01a1d1759125.md) - Frontend rules stated in the docs: TypeScript non-null style, CSS flex helpers, lightweight web components, the Fomantic UI accessibility workarounds, and the issue sidebar combo markup contract.
* [Package Registry Module Layout](package-registry-module-layout--01a1d17590f1.md) - How package registry code is split across models, modules, services and routers, the shared Package/Version/File/Blob model, and which service helper an upload path should call.
* [Testing Expectations](testing-expectations--01a1d1757d86.md) - What the docs require of tests in a change: run the suites before submitting, prefer unit tests over integration tests, keep integration and e2e tests fast, and support every database backend the integration suite runs against.

