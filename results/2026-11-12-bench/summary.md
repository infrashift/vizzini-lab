# Head-to-head review benchmark: 20261112T191951Z-bench

34 cases (29 with labelled defects, 5 clean); models: claude-opus-5-5, claude-sonnet-5-5. 0 findings await a verdict (to-label.jsonl).

| Tool | Model | Failed | Carried | Findings/case | Location recall | Judged recall | Precision (strict / lenient) | Invalid | On clean PRs (invalid) | Decoy hits | Median s | Tokens in/out | Cost |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| vizzini | claude-opus-5-5 | 0/34 | 0 | 4.0 | 88% (45/51) | 76% | 58% / 85% | 21 | 12 (3) | 1 | 20.5 | 261463/82028 | $2.69 |
| vizzini | claude-sonnet-5-5 | 0/34 | 0 | 3.18 | 88% (45/51) | 82% | 59% / 82% | 20 | 8 (2) | 1 | 17.4 | 261463/84949 | $1.37 |
| vizzini-norepo | claude-opus-5-5 | 0/34 | 0 | 4.18 | 88% (45/51) | 72% | 51% / 79% | 30 | 12 (5) | 1 | 21.6 | 193605/85593 | $2.49 |
| vizzini-norepo | claude-sonnet-5-5 | 0/34 | 0 | 3.29 | 86% (44/51) | 78% | 58% / 87% | 15 | 11 (1) | 0 | 17.6 | 199550/86836 | $1.27 |
| vizzini-lint | claude-opus-5-5 | 0/34 | 7 | 3.91 | 88% (45/51) | 76% | 53% / 83% | 23 | 11 (4) | 1 | 19.3 | 263514/80960 | $2.67 |
| vizzini-lint | claude-sonnet-5-5 | 0/34 | 7 | 3.56 | 86% (44/51) | 84% | 58% / 81% | 23 | 10 (2) | 2 | 18.2 | 263514/87804 | $1.41 |
| vizzini-lint-kb | claude-opus-5-5 | 0/34 | 1 | 3.79 | 84% (43/51) | 76% | 56% / 81% | 24 | 13 (4) | 1 | 21.9 | 381254/88060 | $3.29 |
| vizzini-lint-kb | claude-sonnet-5-5 | 0/34 | 1 | 3.24 | 88% (45/51) | 84% | 60% / 84% | 17 | 8 (2) | 1 | 20.0 | 361925/91134 | $1.64 |
| pa | claude-opus-5-5 | 0/34 | 0 | 3.06 | 76% (39/51) | 69% | 76% / 85% | 16 | 6 (2) | 1 | 58.2 | 771643/117148 | $5.43 |
| pa | claude-sonnet-5-5 | 0/34 | 0 | 2.91 | 65% (33/51) | 59% | 67% / 83% | 17 | 8 (1) | 0 | 53.5 | 832908/106297 | $2.73 |
| pa-kb | claude-opus-5-5 | 0/34 | 1 | 3.56 | 69% (35/51) | 61% | 69% / 85% | 18 | 11 (3) | 1 | 69.0 | 1442292/145813 | $8.69 |
| pa-kb | claude-sonnet-5-5 | 0/34 | 1 | 3.0 | 59% (30/51) | 55% | 67% / 79% | 21 | 9 (1) | 0 | 56.2 | 1405425/132290 | $4.13 |
| pa-review | claude-opus-5-5 | 0/34 | 0 | 1.62 | 55% (28/51) | 47% | 73% / 86% | 8 | 4 (1) | 0 | 25.5 | 309552/50276 | $2.24 |
| pa-review | claude-sonnet-5-5 | 0/34 | 0 | 1.44 | 55% (28/51) | 49% | 74% / 86% | 7 | 4 (0) | 0 | 25.4 | 309552/48238 | $1.10 |
| pa-improve | claude-opus-5-5 | 0/34 | 0 | 1.44 | 59% (30/51) | 47% | 80% / 84% | 8 | 2 (1) | 1 | 33.0 | 462091/66872 | $3.19 |
| pa-improve | claude-sonnet-5-5 | 0/34 | 0 | 1.47 | 57% (29/51) | 47% | 60% / 80% | 10 | 4 (1) | 0 | 24.1 | 523356/58059 | $1.63 |
| pa-review-kb | claude-opus-5-5 | 0/34 | 1 | 1.94 | 61% (31/51) | 53% | 67% / 89% | 7 | 6 (1) | 0 | 32.6 | 516897/59905 | $3.27 |
| pa-review-kb | claude-sonnet-5-5 | 0/34 | 1 | 1.38 | 49% (25/51) | 49% | 74% / 85% | 7 | 4 (0) | 0 | 25.5 | 516897/54037 | $1.57 |
| pa-improve-kb | claude-opus-5-5 | 0/34 | 1 | 1.62 | 57% (29/51) | 43% | 73% / 80% | 11 | 5 (2) | 1 | 36.2 | 925395/85908 | $5.42 |
| pa-improve-kb | claude-sonnet-5-5 | 0/34 | 1 | 1.62 | 55% (28/51) | 45% | 60% / 74% | 14 | 5 (1) | 0 | 28.4 | 888528/78253 | $2.56 |

95% bootstrap intervals over cases:

| Tool | Model | Judged recall | Strict precision |
|---|---|---|---|
| vizzini | claude-opus-5-5 | 76% [54%, 90%] | 58% [42%, 72%] |
| vizzini | claude-sonnet-5-5 | 82% [64%, 93%] | 59% [43%, 72%] |
| vizzini-norepo | claude-opus-5-5 | 72% [50%, 86%] | 51% [35%, 65%] |
| vizzini-norepo | claude-sonnet-5-5 | 78% [58%, 90%] | 58% [42%, 72%] |
| vizzini-lint | claude-opus-5-5 | 76% [54%, 90%] | 53% [38%, 67%] |
| vizzini-lint | claude-sonnet-5-5 | 84% [68%, 94%] | 58% [44%, 69%] |
| vizzini-lint-kb | claude-opus-5-5 | 76% [54%, 89%] | 56% [40%, 69%] |
| vizzini-lint-kb | claude-sonnet-5-5 | 84% [68%, 94%] | 60% [45%, 72%] |
| pa | claude-opus-5-5 | 69% [53%, 84%] | 76% [64%, 87%] |
| pa | claude-sonnet-5-5 | 59% [47%, 72%] | 67% [50%, 80%] |
| pa-kb | claude-opus-5-5 | 61% [42%, 80%] | 69% [57%, 80%] |
| pa-kb | claude-sonnet-5-5 | 55% [43%, 72%] | 67% [52%, 80%] |
| pa-review | claude-opus-5-5 | 47% [32%, 62%] | 73% [58%, 86%] |
| pa-review | claude-sonnet-5-5 | 49% [38%, 66%] | 74% [55%, 88%] |
| pa-improve | claude-opus-5-5 | 47% [37%, 63%] | 80% [67%, 91%] |
| pa-improve | claude-sonnet-5-5 | 47% [37%, 60%] | 60% [42%, 77%] |
| pa-review-kb | claude-opus-5-5 | 53% [37%, 68%] | 67% [53%, 79%] |
| pa-review-kb | claude-sonnet-5-5 | 49% [37%, 67%] | 74% [59%, 87%] |
| pa-improve-kb | claude-opus-5-5 | 43% [33%, 57%] | 73% [60%, 84%] |
| pa-improve-kb | claude-sonnet-5-5 | 45% [35%, 60%] | 60% [43%, 76%] |

## Real pull requests only (the seeded fixtures excluded), with 95% bootstrap intervals

| Tool | Model | Defects found | Judged recall | Strict precision | Lenient precision |
|---|---|---|---|---|---|
| vizzini | claude-opus-5-5 | 17/29 | 59% [41%, 77%] | 50% [37%, 62%] | 82% |
| vizzini | claude-sonnet-5-5 | 20/29 | 69% [52%, 86%] | 51% [37%, 65%] | 78% |
| vizzini-norepo | claude-opus-5-5 | 17/29 | 59% [39%, 79%] | 44% [31%, 57%] | 76% |
| vizzini-norepo | claude-sonnet-5-5 | 19/29 | 66% [46%, 83%] | 48% [35%, 61%] | 83% |
| vizzini-lint | claude-opus-5-5 | 17/29 | 59% [38%, 77%] | 45% [33%, 59%] | 80% |
| vizzini-lint | claude-sonnet-5-5 | 21/29 | 72% [56%, 88%] | 50% [38%, 62%] | 77% |
| vizzini-lint-kb | claude-opus-5-5 | 17/29 | 59% [40%, 77%] | 48% [34%, 61%] | 78% |
| vizzini-lint-kb | claude-sonnet-5-5 | 21/29 | 72% [54%, 88%] | 51% [39%, 62%] | 81% |
| pa | claude-opus-5-5 | 19/29 | 66% [48%, 83%] | 74% [61%, 87%] | 83% |
| pa | claude-sonnet-5-5 | 18/29 | 62% [45%, 78%] | 63% [47%, 78%] | 80% |
| pa-kb | claude-opus-5-5 | 17/29 | 59% [40%, 77%] | 67% [54%, 79%] | 83% |
| pa-kb | claude-sonnet-5-5 | 19/29 | 66% [48%, 82%] | 63% [47%, 77%] | 76% |
| pa-review | claude-opus-5-5 | 13/29 | 45% [26%, 64%] | 70% [53%, 85%] | 83% |
| pa-review | claude-sonnet-5-5 | 18/29 | 62% [45%, 78%] | 71% [52%, 89%] | 83% |
| pa-improve | claude-opus-5-5 | 17/29 | 59% [41%, 77%] | 80% [67%, 92%] | 82% |
| pa-improve | claude-sonnet-5-5 | 15/29 | 52% [36%, 68%] | 55% [36%, 74%] | 76% |
| pa-review-kb | claude-opus-5-5 | 15/29 | 52% [33%, 70%] | 63% [48%, 77%] | 88% |
| pa-review-kb | claude-sonnet-5-5 | 18/29 | 62% [44%, 79%] | 72% [56%, 86%] | 82% |
| pa-improve-kb | claude-opus-5-5 | 15/29 | 52% [34%, 69%] | 72% [58%, 84%] | 78% |
| pa-improve-kb | claude-sonnet-5-5 | 16/29 | 55% [38%, 72%] | 55% [38%, 73%] | 70% |

## Paired comparisons, real pull requests only

| A | B | Model | Metric | Difference | Interval | Holds |
|---|---|---|---|---|---|---|
| vizzini | pa | claude-opus-5-5 | judged recall | -7% | [-21%, +6%] | no |
| vizzini | pa | claude-opus-5-5 | strict precision | -25% | [-36%, -13%] | yes |
| vizzini | pa | claude-sonnet-5-5 | judged recall | +7% | [-10%, +22%] | no |
| vizzini | pa | claude-sonnet-5-5 | strict precision | -12% | [-25%, +0%] | no |
| vizzini-lint-kb | pa-kb | claude-opus-5-5 | judged recall | +0% | [-17%, +17%] | no |
| vizzini-lint-kb | pa-kb | claude-opus-5-5 | strict precision | -19% | [-30%, -8%] | yes |
| vizzini-lint-kb | pa-kb | claude-sonnet-5-5 | judged recall | +7% | [-7%, +21%] | no |
| vizzini-lint-kb | pa-kb | claude-sonnet-5-5 | strict precision | -12% | [-25%, +1%] | no |
| vizzini | vizzini-norepo | claude-opus-5-5 | judged recall | +0% | [-13%, +13%] | no |
| vizzini | vizzini-norepo | claude-opus-5-5 | strict precision | +6% | [+0%, +12%] | yes |
| vizzini | vizzini-norepo | claude-sonnet-5-5 | judged recall | +3% | [-13%, +21%] | no |
| vizzini | vizzini-norepo | claude-sonnet-5-5 | strict precision | +2% | [-8%, +12%] | no |
| vizzini-lint | vizzini | claude-opus-5-5 | judged recall | +0% | [-10%, +9%] | no |
| vizzini-lint | vizzini | claude-opus-5-5 | strict precision | -4% | [-9%, +1%] | no |
| vizzini-lint | vizzini | claude-sonnet-5-5 | judged recall | +3% | [-7%, +16%] | no |
| vizzini-lint | vizzini | claude-sonnet-5-5 | strict precision | -1% | [-10%, +8%] | no |
| vizzini-lint-kb | vizzini-lint | claude-opus-5-5 | judged recall | +0% | [-13%, +14%] | no |
| vizzini-lint-kb | vizzini-lint | claude-opus-5-5 | strict precision | +2% | [-4%, +8%] | no |
| vizzini-lint-kb | vizzini-lint | claude-sonnet-5-5 | judged recall | +0% | [-10%, +9%] | no |
| vizzini-lint-kb | vizzini-lint | claude-sonnet-5-5 | strict precision | +1% | [-5%, +7%] | no |
| pa-kb | pa | claude-opus-5-5 | judged recall | -7% | [-18%, +0%] | no |
| pa-kb | pa | claude-opus-5-5 | strict precision | -7% | [-15%, -1%] | yes |
| pa-kb | pa | claude-sonnet-5-5 | judged recall | +3% | [-8%, +14%] | no |
| pa-kb | pa | claude-sonnet-5-5 | strict precision | +0% | [-5%, +6%] | no |

## Paired comparisons, all cases (A minus B, same cases; 95% bootstrap interval; 'holds' when it excludes 0)

| A | B | Model | Metric | Difference | Interval | Holds |
|---|---|---|---|---|---|---|
| vizzini | pa | claude-opus-5-5 | judged recall | +8% | [-11%, +24%] | no |
| vizzini | pa | claude-opus-5-5 | strict precision | -18% | [-30%, -7%] | yes |
| vizzini | pa | claude-sonnet-5-5 | judged recall | +24% | [+3%, +38%] | yes |
| vizzini | pa | claude-sonnet-5-5 | strict precision | -7% | [-20%, +4%] | no |
| vizzini-lint-kb | pa-kb | claude-opus-5-5 | judged recall | +16% | [-7%, +37%] | no |
| vizzini-lint-kb | pa-kb | claude-opus-5-5 | strict precision | -14% | [-25%, -3%] | yes |
| vizzini-lint-kb | pa-kb | claude-sonnet-5-5 | judged recall | +29% | [+3%, +44%] | yes |
| vizzini-lint-kb | pa-kb | claude-sonnet-5-5 | strict precision | -7% | [-19%, +4%] | no |
| vizzini | vizzini-norepo | claude-opus-5-5 | judged recall | +4% | [-6%, +13%] | no |
| vizzini | vizzini-norepo | claude-opus-5-5 | strict precision | +7% | [+2%, +13%] | yes |
| vizzini | vizzini-norepo | claude-sonnet-5-5 | judged recall | +4% | [-7%, +17%] | no |
| vizzini | vizzini-norepo | claude-sonnet-5-5 | strict precision | +1% | [-7%, +9%] | no |
| vizzini-lint | vizzini | claude-opus-5-5 | judged recall | +0% | [-6%, +6%] | no |
| vizzini-lint | vizzini | claude-opus-5-5 | strict precision | -5% | [-10%, +0%] | no |
| vizzini-lint | vizzini | claude-sonnet-5-5 | judged recall | +2% | [-5%, +10%] | no |
| vizzini-lint | vizzini | claude-sonnet-5-5 | strict precision | -1% | [-9%, +6%] | no |
| vizzini-lint-kb | vizzini-lint | claude-opus-5-5 | judged recall | +0% | [-9%, +8%] | no |
| vizzini-lint-kb | vizzini-lint | claude-opus-5-5 | strict precision | +2% | [-3%, +8%] | no |
| vizzini-lint-kb | vizzini-lint | claude-sonnet-5-5 | judged recall | +0% | [-6%, +6%] | no |
| vizzini-lint-kb | vizzini-lint | claude-sonnet-5-5 | strict precision | +2% | [-3%, +7%] | no |
| pa-kb | pa | claude-opus-5-5 | judged recall | -8% | [-16%, +0%] | no |
| pa-kb | pa | claude-opus-5-5 | strict precision | -6% | [-14%, -1%] | yes |
| pa-kb | pa | claude-sonnet-5-5 | judged recall | -4% | [-16%, +9%] | no |
| pa-kb | pa | claude-sonnet-5-5 | strict precision | +0% | [-4%, +5%] | no |

## Per case (judged hits / defects; findings)

| Case | Kind | vizzini opus | vizzini sonnet | vizzini-lint opus | vizzini-lint sonnet | vizzini-lint-kb opus | vizzini-lint-kb sonnet | pa opus | pa sonnet | pa-kb opus | pa-kb sonnet |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cs-aspnetcore-rewrite-backslash | buggy | 1/1 (1 loc); 5 | 1/1 (1 loc); 4 | 1/1 (1 loc); 5 (carried) | 1/1 (1 loc); 4 (carried) | 0/1 (0 loc); 4 | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 | 1/1 (1 loc); 4 | 1/1 (1 loc); 3 |
| cs-avalonia-commandbar-overflow-clean | clean | 3 | 2 | 3 (carried) | 2 (carried) | 2 | 2 | 0 | 2 | 2 | 1 |
| cs-avalonia-popup-pointer-resize | buggy | 0/1 (1 loc); 5 | 0/1 (1 loc); 4 | 0/1 (1 loc); 5 (carried) | 0/1 (1 loc); 4 (carried) | 0/1 (1 loc); 5 | 0/1 (1 loc); 3 | 0/1 (1 loc); 5 | 0/1 (1 loc); 5 | 0/1 (1 loc); 5 | 0/1 (1 loc); 5 |
| cs-avalonia-vsp-anchor-at-end | buggy | 0/1 (1 loc); 4 | 1/1 (1 loc); 2 | 0/1 (1 loc); 4 (carried) | 1/1 (1 loc); 2 (carried) | 0/1 (0 loc); 1 | 0/1 (1 loc); 3 | 0/1 (1 loc); 3 | 0/1 (0 loc); 1 | 0/1 (1 loc); 3 | 0/1 (0 loc); 3 |
| cs-efcore-executedelete-commandsource | buggy | 1/1 (1 loc); 3 | 1/1 (1 loc); 3 | 1/1 (1 loc); 3 (carried) | 1/1 (1 loc); 3 (carried) | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 5 | 1/1 (1 loc); 3 |
| csharp-seeded | buggy | 9/9 (9 loc); 12 | 9/9 (9 loc); 8 | 9/9 (9 loc); 9 | 9/9 (9 loc); 10 | 9/9 (9 loc); 8 | 9/9 (9 loc); 9 | 9/9 (8 loc); 6 | 6/9 (6 loc); 6 | 9/9 (8 loc); 6 | 3/9 (3 loc); 6 |
| ctx-seeded | buggy | 3/3 (3 loc); 5 | 3/3 (3 loc); 5 | 3/3 (3 loc); 5 | 3/3 (3 loc); 5 | 3/3 (3 loc); 5 (carried) | 3/3 (3 loc); 5 (carried) | 2/3 (2 loc); 6 | 2/3 (2 loc); 4 | 2/3 (2 loc); 6 (carried) | 2/3 (2 loc); 4 (carried) |
| go-cilium-mapstate-prefix | buggy | 0/1 (0 loc); 7 | 0/1 (0 loc); 5 | 0/1 (0 loc); 8 | 0/1 (0 loc); 4 | 0/1 (0 loc); 6 | 0/1 (0 loc); 5 | 1/1 (1 loc); 3 | 0/1 (0 loc); 2 | 1/1 (1 loc); 4 | 0/1 (0 loc); 1 |
| go-gitea-diff-linecount-shadow | buggy | 0/1 (1 loc); 6 | 0/1 (1 loc); 5 | 0/1 (1 loc); 8 | 0/1 (1 loc); 5 | 0/1 (1 loc); 6 | 0/1 (1 loc); 4 | 1/1 (1 loc); 4 | 0/1 (1 loc); 4 | 1/1 (1 loc); 6 | 1/1 (1 loc); 4 |
| go-gitea-runner-bulk-empty-ids | buggy | 1/1 (1 loc); 3 | 1/1 (1 loc); 3 | 1/1 (1 loc); 3 | 1/1 (1 loc); 5 | 1/1 (1 loc); 5 | 1/1 (1 loc); 4 | 1/1 (1 loc); 5 | 1/1 (1 loc); 4 | 1/1 (1 loc); 5 | 1/1 (1 loc); 4 |
| go-gitea-tail-diffline-empty | buggy | 0/1 (0 loc); 6 | 0/1 (0 loc); 3 | 0/1 (0 loc); 6 | 0/1 (0 loc); 1 | 0/1 (0 loc); 6 | 0/1 (0 loc); 2 | 0/1 (0 loc); 0 | 0/1 (0 loc); 2 | 0/1 (0 loc); 0 | 0/1 (0 loc); 2 |
| go-helm-ssa-conflict-retry-clean | clean | 2 | 1 | 3 | 2 | 2 | 1 | 0 | 1 | 0 | 2 |
| go-otelcol-hostwrapper-capabilities | buggy | 1/1 (1 loc); 3 | 0/1 (0 loc); 3 | 1/1 (1 loc); 3 | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 4 | 1/1 (1 loc); 3 |
| go-rclone-shade-complete-eof | buggy | 0/1 (1 loc); 2 | 0/1 (1 loc); 2 | 0/1 (0 loc); 1 | 0/1 (0 loc); 1 | 0/1 (0 loc); 2 | 0/1 (0 loc); 1 | 0/1 (0 loc); 3 | 0/1 (0 loc); 4 | 0/1 (0 loc); 2 | 0/1 (1 loc); 4 |
| go-tailscale-controld-doh-clean | clean | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |
| go-tailscale-socks5-halfclose | buggy | 2/2 (2 loc); 7 | 2/2 (2 loc); 4 | 2/2 (2 loc); 5 | 2/2 (2 loc); 7 | 2/2 (2 loc); 6 | 2/2 (2 loc); 7 | 2/2 (2 loc); 6 | 2/2 (2 loc); 5 | 2/2 (2 loc); 5 | 2/2 (2 loc); 5 |
| js-fastify-forceclose-idle | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 |
| js-node-child-process-env-reassigned | buggy | 1/1 (1 loc); 3 | 0/1 (0 loc); 3 | 0/1 (0 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 0/1 (1 loc); 2 | 1/1 (1 loc); 4 | 0/1 (1 loc); 3 | 1/1 (1 loc); 1 |
| js-node-stream-asynciter-undefined | buggy | 0/2 (2 loc); 3 | 2/2 (2 loc); 4 | 0/2 (2 loc); 4 | 2/2 (1 loc); 5 | 0/2 (2 loc); 4 | 2/2 (1 loc); 4 | 0/2 (2 loc); 5 | 1/2 (2 loc); 4 | 0/2 (2 loc); 6 | 2/2 (2 loc); 4 |
| js-prettier-markdown-cj-null-deref | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 | 1/1 (1 loc); 3 | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 |
| js-undici-frozen-globalthis-clean | clean | 4 | 3 | 4 | 5 | 5 | 4 | 4 | 4 | 6 | 5 |
| js-undici-h2-maxconcurrentstreams-validation | buggy | 1/1 (1 loc); 9 | 1/1 (1 loc); 8 | 1/1 (1 loc); 10 | 1/1 (1 loc); 10 | 1/1 (1 loc); 10 | 1/1 (1 loc); 9 | 1/1 (1 loc); 6 | 1/1 (1 loc); 6 | 1/1 (1 loc); 6 | 1/1 (1 loc); 6 |
| py-django-cacheddb-delete-logging-clean | clean | 3 | 1 | 1 | 1 | 3 | 1 | 2 | 1 | 3 | 1 |
| py-django-nonatomic-async | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 |
| py-django-verbatim-lexer | buggy | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 | 1/1 (1 loc); 3 | 1/1 (1 loc); 3 | 1/1 (1 loc); 4 | 1/1 (1 loc); 3 | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 | 1/1 (1 loc); 4 | 1/1 (1 loc); 2 |
| py-django-yaml-sortkeys | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |
| py-numpy-linspace-subclass | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 3 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 0/1 (0 loc); 1 | 0/1 (0 loc); 0 |
| py-pandas-agg-func-names-truthiness | buggy | 0/1 (0 loc); 3 | 0/1 (0 loc); 2 | 0/1 (0 loc); 0 | 0/1 (0 loc); 3 | 0/1 (0 loc); 2 | 0/1 (0 loc); 2 | 0/1 (0 loc); 0 | 0/1 (0 loc); 0 | 0/1 (0 loc); 3 | 0/1 (0 loc); 2 |
| py-pytest-initial-conftest-testdirs | buggy | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |
| rs-rust-analyzer-fetch-semantic | buggy | 1/1 (1 loc); 2 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 (carried) | 1/1 (1 loc); 1 (carried) | 1/1 (1 loc); 3 | 1/1 (1 loc); 1 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 | 1/1 (1 loc); 2 |
| rs-tokio-pidfd-child-leak | buggy | 0/1 (0 loc); 5 | 1/1 (1 loc); 4 | 0/1 (0 loc); 5 (carried) | 1/1 (1 loc); 4 (carried) | 1/1 (1 loc); 5 | 1/1 (1 loc); 5 | 1/1 (1 loc); 5 | 0/1 (0 loc); 4 | 0/1 (0 loc); 3 | 0/1 (0 loc); 5 |
| ts-react-router-manifest-paths-comma | buggy | 1/2 (1 loc); 4 | 2/2 (2 loc); 3 | 2/2 (2 loc); 5 | 1/2 (1 loc); 4 | 1/2 (1 loc); 5 | 2/2 (2 loc); 4 | 1/2 (1 loc); 5 | 1/2 (1 loc); 5 | 1/2 (1 loc); 6 | 1/2 (1 loc); 5 |
| ts-seeded | buggy | 10/10 (10 loc); 10 | 10/10 (10 loc); 10 | 10/10 (10 loc); 11 | 10/10 (10 loc); 10 | 10/10 (10 loc); 11 | 10/10 (10 loc); 11 | 5/10 (5 loc); 6 | 4/10 (4 loc); 6 | 3/10 (3 loc); 6 | 4/10 (4 loc); 6 |
| ts-vue-vapor-slot-close-lazy | buggy | 0/1 (0 loc); 2 | 0/1 (0 loc); 2 | 0/1 (1 loc); 2 | 0/1 (0 loc); 3 | 0/1 (0 loc); 1 | 0/1 (0 loc); 1 | 0/1 (0 loc); 4 | 0/1 (0 loc); 2 | 0/1 (0 loc); 2 | 0/1 (0 loc); 2 |
