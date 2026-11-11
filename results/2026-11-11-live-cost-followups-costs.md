# Cost attribution for run 20261111T181101Z

Reports counted 4 request(s) in their usage blocks; LiteLLM recorded 4 for those runs.

```
  fixture  |       model       |   mode   | requests | in_tok | out_tok | cost_usd | wasted_usd | findings | per_finding 
-----------+-------------------+----------+----------+--------+---------+----------+------------+----------+-------------
 ts-seeded | claude-sonnet-5-5 | describe |        1 |   2053 |    1192 | 0.016026 |   0.000000 |          |            
 ts-seeded | claude-sonnet-5-5 | improve  |        1 |   2147 |    3496 | 0.039254 |   0.000000 |          |            
 ts-seeded | claude-sonnet-5-5 | plan     |        1 |   1002 |    2378 | 0.025784 |   0.000000 |          |            
 ts-seeded | claude-sonnet-5-5 | review   |        1 |   3582 |    2820 | 0.035364 |   0.000000 |       10 |    0.003536
(4 rows)

                         pr_key                          | iterations | runs | requests | cost_usd 
---------------------------------------------------------+------------+------+----------+----------
 ado:dev.azure.com/ryanscraig/scratch/vizzini-scratch#12 |          1 |    4 |        4 | 0.116428
(1 row)

```
