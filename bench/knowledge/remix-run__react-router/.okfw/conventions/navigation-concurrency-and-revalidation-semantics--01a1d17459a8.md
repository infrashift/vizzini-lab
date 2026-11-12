---
id: "01a1d174-59a8-7d3a-97cd-19c5c91605cf"
title: "Navigation Concurrency and Revalidation Semantics"
type: "Guideline"
tags:
  - "concurrency"
  - "race-conditions"
  - "revalidation"
  - "fetchers"
created: "2026-11-12T14:30:25-06:00"
timestamp: "2026-11-12T14:30:25-06:00"
description: "The router mirrors browser behavior by cancelling interrupted navigations and stale revalidations, revalidates all active data after mutations, and manages history entries for form submissions."
x:
  paths: ["packages/react-router/lib/router/**", "packages/react-router/lib/hooks.tsx", "packages/react-router/lib/dom/lib.tsx"]
  source: ["docs/explanation/race-conditions.md", "decisions/0005-remixing-react-router.md"]
---

# Navigation Concurrency and Revalidation Semantics

React Router's handling of network concurrency "is heavily inspired by the behavior of web browsers". Changes to the router's navigation, fetcher or revalidation code should keep these documented guarantees.

## Interruption and cancellation

- Like a browser, a new link navigation or form submission cancels the in-flight data requests of the one it interrupts and is processed immediately.
- Fetchers are not singletons: one fetcher cannot interrupt another, but a fetcher interrupts itself (for example, repeated `fetcher.submit` calls cancel that fetcher's pending request).
- After a fetcher action returns, a revalidation of all page data is sent, so several revalidations can be in flight at once. The router "will commit all 'fresh' revalidation responses and cancel any stale requests", where stale means a request that started earlier than one that has already returned.
- Server-side race conditions from cancelled requests that the server still processes are stated to be out of scope, the same as with plain HTML forms.

## Revalidation

- Revalidation updates *all* active loaded data: route loaders and active `fetcher.load()` data. Each can opt out through `shouldRevalidate`.
- `shouldRevalidate` is called during all revalidations and receives a `defaultShouldRevalidate` boolean, so user logic can handle an edge case and otherwise return the default.
- `useRevalidator()` lets users trigger revalidation manually.

## Navigation state

- `useNavigation()` returns `state` (`"idle" | "loading" | "submitting"`), `location`, and flattened `formMethod`, `formAction`, `formEncType`, `formData`.
- `<Form method="get">` is a navigation, not a submission, so its state is `"loading"`, matching what a plain link would do.

## History entries for submissions

- A POST submission whose action does not redirect uses REPLACE, so the history stack does not get a duplicate entry.
- A POST whose action redirects uses PUSH for the redirect, so the page that held the form stays in history.
- An explicit `replace` value on `<Form>` is always respected.
- `<ScrollRestoration>` restores by `location.key` by default (or a user `getKey`), and resets scroll to top on new locations unless `preventScrollReset` is set for that navigation.
