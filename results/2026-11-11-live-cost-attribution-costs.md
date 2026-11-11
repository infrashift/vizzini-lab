# Cost attribution for run 20261111T175706Z

Reviews counted 4 request(s) in their usage blocks; LiteLLM recorded 4 for the review runs.

```
    fixture    |       model       | requests | in_tok | out_tok | cost_usd | wasted_usd | findings | per_finding 
---------------+-------------------+----------+--------+---------+----------+------------+----------+-------------
 csharp-seeded | claude-opus-5-5   |        1 |   4850 |    2856 | 0.076520 |   0.000000 |       11 |    0.006956
 csharp-seeded | claude-sonnet-5-5 |        1 |   4850 |    4055 | 0.050250 |   0.000000 |        9 |    0.005583
 ts-seeded     | claude-opus-5-5   |        1 |   3582 |    2169 | 0.057708 |   0.000000 |       11 |    0.005246
 ts-seeded     | claude-sonnet-5-5 |        1 |   3582 |    3169 | 0.038854 |   0.000000 |       11 |    0.003532
(4 rows)

            pr_key             | iterations | runs | requests | cost_usd 
-------------------------------+------------+------+----------+----------
 uat:vizzini-uat/csharp-seeded |          1 |    8 |        8 | 0.365958
 uat:vizzini-uat/ts-seeded     |          2 |    8 |        8 | 0.267922
(2 rows)

```
