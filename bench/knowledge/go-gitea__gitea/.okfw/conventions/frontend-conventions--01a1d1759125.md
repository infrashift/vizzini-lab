---
id: "01a1d175-9125-7065-87cf-4704c8b22ed6"
title: "Frontend Conventions"
type: "Guideline"
tags:
  - "frontend"
  - "typescript"
  - "css"
  - "accessibility"
  - "web-components"
created: "2026-11-12T14:31:45-06:00"
timestamp: "2026-11-12T14:31:45-06:00"
description: "Frontend rules stated in the docs: TypeScript non-null style, CSS flex helpers, lightweight web components, the Fomantic UI accessibility workarounds, and the issue sidebar combo markup contract."
x:
  paths: ["web_src/js/**", "web_src/css/**", "vite.config.ts"]
  source: ["AGENTS.md", "web_src/js/webcomponents/README.md", "web_src/js/modules/fomantic/aria.md", "web_src/js/features/repo-issue-sidebar.md", "docs/guideline-frontend.md"]
---

# Frontend Conventions

## TypeScript and CSS (AGENTS.md)

- When a value is known to always exist, use the `!` non-null assertion instead of `?.` or `??`.
- For CSS layout, prefer `flex-*` helpers over per-child `tw-ml-*` / `tw-mr-*` margins. Fall back to `tw-*` utilities when specificity requires `!important`.
- Lint TypeScript with `make lint-js`; run frontend unit tests with `pnpm exec vitest <path-filter>`.

## Web components

Web components in `web_src/js/webcomponents/` are loaded in `<head>` through a separate entry point, before the page body, so:

- They must be lightweight so they do not slow page loading.
- Do not import `svg.js` into a web component, because it is not tree-shakeable; import individual SVG files instead.
- Every component must be added to `vite.config.ts` so it works correctly in Vue.

## Fomantic UI accessibility layer

Fomantic UI has many accessibility problems. The files in `web_src/js/modules/fomantic/` work around them and are deliberately designed "to avoid touching the official Fomantic UI library" and to stay independent so they can be modified or removed later. Points a reviewer can check:

- Fomantic-style checkboxes get IDs and linked labels from JS (`initAriaLabels`); a checkbox with an empty label needs a manual `aria-label`.
- Dropdowns with an input behave as a combobox; dropdowns without one behave as a menu. Fomantic Dropdown requires focus to stay on its primary element. Multiple-selection dropdowns are not well supported yet.
- The doc describes manual screen-reader testing with VoiceOver and TalkBack.

## Issue sidebar combo

`repo-issue-sidebar.md` defines the markup contract for a dropdown-plus-list combo (`.issue-sidebar-combo` with `data-selection-mode`, optional `data-update-url`, a hidden `.combo-value` input, a `.ui.dropdown` and an optional `.ui.list`). Rules from that doc:

- Menu items must have a correct `href`, or the cloned list items will link to the wrong place.
- Items with the same `data-scope` allow only one selection at a time.
- `single` mode updates immediately; `multiple` mode defers the update until the dropdown is hidden.
- In a scrolling menu, items must be at the same level or keyboard navigation breaks.

## Dependencies and further guidelines

Frontend dependency changes follow the same policy as Go dependencies (see the "Dependency Change Policy" concept). The frontend guideline links to fuller backend, frontend and refactoring guidelines hosted on the documentation site, which are not part of this repository's docs.
