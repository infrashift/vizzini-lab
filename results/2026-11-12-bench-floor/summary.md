# Head-to-head review benchmark: 20261112T225829Z-bench-floor2

34 cases (29 with labelled defects, 5 clean); models: claude-opus-5-5, claude-sonnet-5-5. 0 findings await a verdict (to-label.jsonl).

| Tool | Model | Failed | Carried | Findings/case | Location recall | Judged recall | Precision (strict / lenient) | Invalid | On clean PRs (invalid) | Decoy hits | Median s | Tokens in/out | Cost |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| vizzini | claude-opus-5-5 | 0/34 | 0 | 3.0 | 86% (44/51) | 78% | 76% / 90% | 10 | 9 (2) | 0 | 20.5 | 268054/76473 | $2.60 |
| vizzini | claude-sonnet-5-5 | 0/34 | 0 | 2.74 | 88% (45/51) | 84% | 74% / 89% | 10 | 9 (3) | 1 | 16.4 | 285005/80514 | $1.38 |
| vizzini+filtered | claude-opus-5-5 | 0/34 | 0 | 3.62 | 86% (44/51) | 78% | 64% / 91% | 11 | 10 (2) | 0 | 20.5 | 268054/76473 | $2.60 |
| vizzini+filtered | claude-sonnet-5-5 | 0/34 | 0 | 3.18 | 88% (45/51) | 84% | 65% / 91% | 10 | 11 (3) | 2 | 16.4 | 285005/80514 | $1.38 |
| pa | claude-opus-5-5 | 0/34 | 0 | 3.06 | 76% (39/51) | 69% | 76% / 85% | 16 | 6 (2) | 1 | 58.2 | 771643/117148 | $5.43 |
| pa | claude-sonnet-5-5 | 0/34 | 0 | 2.91 | 65% (33/51) | 59% | 67% / 83% | 17 | 8 (1) | 0 | 53.5 | 832908/106297 | $2.73 |
| pa-review | claude-opus-5-5 | 0/34 | 0 | 1.62 | 55% (28/51) | 47% | 73% / 86% | 8 | 4 (1) | 0 | 25.5 | 309552/50276 | $2.24 |
| pa-review | claude-sonnet-5-5 | 0/34 | 0 | 1.44 | 55% (28/51) | 49% | 74% / 86% | 7 | 4 (0) | 0 | 25.4 | 309552/48238 | $1.10 |
| pa-improve | claude-opus-5-5 | 0/34 | 0 | 1.44 | 59% (30/51) | 47% | 80% / 84% | 8 | 2 (1) | 1 | 33.0 | 462091/66872 | $3.19 |
| pa-improve | claude-sonnet-5-5 | 0/34 | 0 | 1.47 | 57% (29/51) | 47% | 60% / 80% | 10 | 4 (1) | 0 | 24.1 | 523356/58059 | $1.63 |

95% bootstrap intervals over cases:

| Tool | Model | Judged recall | Strict precision |
|---|---|---|---|
| vizzini | claude-opus-5-5 | 78% [58%, 90%] | 76% [62%, 86%] |
| vizzini | claude-sonnet-5-5 | 84% [67%, 94%] | 74% [61%, 85%] |
| vizzini+filtered | claude-opus-5-5 | 78% [58%, 90%] | 64% [48%, 78%] |
| vizzini+filtered | claude-sonnet-5-5 | 84% [67%, 94%] | 65% [50%, 78%] |
| pa | claude-opus-5-5 | 69% [52%, 84%] | 76% [63%, 87%] |
| pa | claude-sonnet-5-5 | 59% [47%, 72%] | 67% [52%, 80%] |
| pa-review | claude-opus-5-5 | 47% [33%, 62%] | 73% [57%, 86%] |
| pa-review | claude-sonnet-5-5 | 49% [38%, 67%] | 74% [57%, 89%] |
| pa-improve | claude-opus-5-5 | 47% [37%, 65%] | 80% [66%, 91%] |
| pa-improve | claude-sonnet-5-5 | 47% [36%, 60%] | 60% [42%, 76%] |

## Real pull requests only (the seeded fixtures excluded), with 95% bootstrap intervals

| Tool | Model | Defects found | Judged recall | Strict precision | Lenient precision |
|---|---|---|---|---|---|
| vizzini | claude-opus-5-5 | 18/29 | 62% [45%, 79%] | 68% [56%, 80%] | 87% |
| vizzini | claude-sonnet-5-5 | 21/29 | 72% [56%, 88%] | 69% [55%, 82%] | 87% |
| vizzini+filtered | claude-opus-5-5 | 18/29 | 62% [45%, 79%] | 56% [41%, 71%] | 89% |
| vizzini+filtered | claude-sonnet-5-5 | 21/29 | 72% [56%, 88%] | 58% [43%, 73%] | 89% |
| pa | claude-opus-5-5 | 19/29 | 66% [48%, 83%] | 74% [60%, 88%] | 83% |
| pa | claude-sonnet-5-5 | 18/29 | 62% [45%, 79%] | 63% [46%, 78%] | 80% |
| pa-review | claude-opus-5-5 | 13/29 | 45% [26%, 64%] | 70% [52%, 86%] | 83% |
| pa-review | claude-sonnet-5-5 | 18/29 | 62% [45%, 79%] | 71% [51%, 89%] | 83% |
| pa-improve | claude-opus-5-5 | 17/29 | 59% [42%, 77%] | 80% [66%, 92%] | 82% |
| pa-improve | claude-sonnet-5-5 | 15/29 | 52% [35%, 68%] | 55% [36%, 74%] | 76% |

## Paired comparisons, real pull requests only

| A | B | Model | Metric | Difference | Interval | Holds |
|---|---|---|---|---|---|---|
| vizzini | vizzini+filtered | claude-opus-5-5 | judged recall | +0% | [+0%, +0%] | no |
| vizzini | vizzini+filtered | claude-opus-5-5 | strict precision | +13% | [+6%, +19%] | yes |
| vizzini | vizzini+filtered | claude-sonnet-5-5 | judged recall | +0% | [+0%, +0%] | no |
| vizzini | vizzini+filtered | claude-sonnet-5-5 | strict precision | +11% | [+5%, +16%] | yes |
| vizzini | pa | claude-opus-5-5 | judged recall | -3% | [-19%, +11%] | no |
| vizzini | pa | claude-opus-5-5 | strict precision | -6% | [-18%, +6%] | no |
| vizzini | pa | claude-sonnet-5-5 | judged recall | +10% | [+0%, +21%] | no |
| vizzini | pa | claude-sonnet-5-5 | strict precision | +6% | [-9%, +21%] | no |

## Paired comparisons, all cases (A minus B, same cases; 95% bootstrap interval; 'holds' when it excludes 0)

| A | B | Model | Metric | Difference | Interval | Holds |
|---|---|---|---|---|---|---|
| vizzini | vizzini+filtered | claude-opus-5-5 | judged recall | +0% | [+0%, +0%] | no |
| vizzini | vizzini+filtered | claude-opus-5-5 | strict precision | +11% | [+5%, +17%] | yes |
| vizzini | vizzini+filtered | claude-sonnet-5-5 | judged recall | +0% | [+0%, +0%] | no |
| vizzini | vizzini+filtered | claude-sonnet-5-5 | strict precision | +9% | [+4%, +14%] | yes |
| vizzini | pa | claude-opus-5-5 | judged recall | +10% | [-10%, +26%] | no |
| vizzini | pa | claude-opus-5-5 | strict precision | -0% | [-12%, +9%] | no |
| vizzini | pa | claude-sonnet-5-5 | judged recall | +26% | [+8%, +38%] | yes |
| vizzini | pa | claude-sonnet-5-5 | strict precision | +8% | [-4%, +19%] | no |

## Per case (judged hits / defects; findings)

| Case | Kind | vizzini opus | vizzini sonnet | vizzini-lint opus | vizzini-lint sonnet | vizzini-lint-kb opus | vizzini-lint-kb sonnet | pa opus | pa sonnet | pa-kb opus | pa-kb sonnet |
|---|---|---|---|---|---|---|---|---|---|---|---|
| csharp-seeded | buggy | 9/9 (9 loc); 11 | 9/9 (9 loc); 11 |  |  |  |  | 9/9 (8 loc); 6 | 6/9 (6 loc); 6 |  |  |
| ts-seeded | buggy | 10/10 (10 loc); 11 | 10/10 (10 loc); 10 |  |  |  |  | 5/10 (5 loc); 6 | 4/10 (4 loc); 6 |  |  |
| ctx-seeded | buggy | 3/3 (3 loc); 4 | 3/3 (3 loc); 5 |  |  |  |  | 2/3 (2 loc); 6 | 2/3 (2 loc); 4 |  |  |
| go-gitea-tail-diffline-empty | buggy | 0/1 (0 loc); 2 | 0/1 (0 loc); 1 |  |  |  |  | 0/1 (0 loc); 0 | 0/1 (0 loc); 2 |  |  |
| go-gitea-diff-linecount-shadow | buggy | 0/1 (1 loc); 4 | 0/1 (1 loc); 4 |  |  |  |  | 1/1 (1 loc); 4 | 0/1 (1 loc); 4 |  |  |
| go-gitea-runner-bulk-empty-ids | buggy | 1/1 (1 loc); 5 | 1/1 (1 loc); 4 |  |  |  |  | 1/1 (1 loc); 5 | 1/1 (1 loc); 4 |  |  |
| go-tailscale-socks5-halfclose | buggy | 2/2 (2 loc); 4 | 2/2 (2 loc); 3 |  |  |  |  | 2/2 (2 loc); 6 | 2/2 (2 loc); 5 |  |  |
| go-rclone-shade-complete-eof | buggy | 0/1 (0 loc); 2 | 0/1 (0 loc); 1 |  |  |  |  | 0/1 (0 loc); 3 | 0/1 (0 loc); 4 |  |  |
| go-otelcol-hostwrapper-capabilities | buggy | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |
| go-cilium-mapstate-prefix | buggy | 0/1 (0 loc); 4 | 0/1 (0 loc); 2 |  |  |  |  | 1/1 (1 loc); 3 | 0/1 (0 loc); 2 |  |  |
| js-node-stream-asynciter-undefined | buggy | 1/2 (2 loc); 5 | 2/2 (2 loc); 3 |  |  |  |  | 0/2 (2 loc); 5 | 1/2 (2 loc); 4 |  |  |
| js-node-child-process-env-reassigned | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 |  |  |  |  | 0/1 (1 loc); 2 | 1/1 (1 loc); 4 |  |  |
| js-prettier-markdown-cj-null-deref | buggy | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 |  |  |
| ts-vue-vapor-slot-close-lazy | buggy | 0/1 (0 loc); 2 | 0/1 (0 loc); 1 |  |  |  |  | 0/1 (0 loc); 4 | 0/1 (0 loc); 2 |  |  |
| js-undici-h2-maxconcurrentstreams-validation | buggy | 1/1 (1 loc); 7 | 1/1 (1 loc); 7 |  |  |  |  | 1/1 (1 loc); 6 | 1/1 (1 loc); 6 |  |  |
| js-fastify-forceclose-idle | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 |  |  |
| ts-react-router-manifest-paths-comma | buggy | 1/2 (1 loc); 4 | 1/2 (1 loc); 3 |  |  |  |  | 1/2 (1 loc); 5 | 1/2 (1 loc); 5 |  |  |
| py-django-verbatim-lexer | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |  |  | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 |  |  |
| py-django-nonatomic-async | buggy | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |
| py-django-yaml-sortkeys | buggy | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |
| py-pandas-agg-func-names-truthiness | buggy | 0/1 (0 loc); 0 | 0/1 (0 loc); 1 |  |  |  |  | 0/1 (0 loc); 0 | 0/1 (0 loc); 0 |  |  |
| py-pytest-initial-conftest-testdirs | buggy | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |
| py-numpy-linspace-subclass | buggy | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 |  |  |
| cs-aspnetcore-rewrite-backslash | buggy | 1/1 (1 loc); 5 | 1/1 (1 loc); 4 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 |  |  |
| cs-avalonia-vsp-anchor-at-end | buggy | 0/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |  |  | 0/1 (1 loc); 3 | 0/1 (0 loc); 1 |  |  |
| cs-avalonia-popup-pointer-resize | buggy | 0/1 (1 loc); 3 | 0/1 (1 loc); 3 |  |  |  |  | 0/1 (1 loc); 5 | 0/1 (1 loc); 5 |  |  |
| cs-efcore-executedelete-commandsource | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |
| rs-tokio-pidfd-child-leak | buggy | 0/1 (0 loc); 2 | 1/1 (1 loc); 3 |  |  |  |  | 1/1 (1 loc); 5 | 0/1 (0 loc); 4 |  |  |
| rs-rust-analyzer-fetch-semantic | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 |  |  |  |  | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |  |  |
| go-helm-ssa-conflict-retry-clean | clean | 1 | 2 |  |  |  |  | 0 | 1 |  |  |
| go-tailscale-controld-doh-clean | clean | 1 | 0 |  |  |  |  | 0 | 0 |  |  |
| js-undici-frozen-globalthis-clean | clean | 4 | 5 |  |  |  |  | 4 | 4 |  |  |
| py-django-cacheddb-delete-logging-clean | clean | 1 | 1 |  |  |  |  | 2 | 1 |  |  |
| cs-avalonia-commandbar-overflow-clean | clean | 2 | 1 |  |  |  |  | 0 | 2 |  |  |
