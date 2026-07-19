-- Query 105_recency_monetary_funnel_fixed_bucket_check
-- WHAT: Bin customers by recency_days into fixed 50-day buckets, and show
--       MAX and AVG monetary_gross per bucket, to test whether high-monetary
--       customers ever appear past a certain recency threshold.
-- WHY: Chapter Three's rotating 3D chart suggested a "recency-monetary
--      funnel" — no customer with recency past ~300-400 days ever reaches
--      high monetary value. Per this project's standing rule (visualization
--      suggests, SQL confirms), this claim had not yet been run through a
--      query. Fixed-width bucketing mirrors query 99's approach and gives
--      a round, defensible day-cutoff if the funnel pattern holds.

SELECT
    (recency_days / 50) * 50 AS recency_bucket_start,
    (recency_days / 50) * 50 + 49 AS recency_bucket_end,
    COUNT(*) AS customer_count,
    MAX(monetary_gross) AS max_monetary_gross,
    AVG(monetary_gross) AS avg_monetary_gross
FROM uk_retail.customer_behavior_fields
WHERE recency_days IS NOT NULL  -- excludes the 23 never-converted customers
GROUP BY (recency_days / 50)
ORDER BY recency_bucket_start;

-- RESULT (run July 18, 2026):
-- AVG monetary_gross decays steadily with recency (5,545 -> 261 across the
-- full range), confirming the funnel holds for the typical/average customer.
-- MAX monetary_gross does NOT funnel — it is erratic across the entire
-- range, including a 300-349 day spike to £77,352.96, a 350-399 day spike
-- to £65,500.07, and a 600-649 day spike to £34,023.26. High-value outliers
-- ("lapsed whales") exist at every recency range, all the way past 600 days.
--
-- CONFIRMED FINDING (revised from Chapter Three's original visual claim):
-- Average customer spend declines steadily as recency increases, but a
-- small population of high-value outliers exists at every recency level.
-- The funnel governs the typical customer; it does not govern the tail.
-- See query 106 for the independently-derived quartile-crosstab fork,
-- which confirms this same revised finding from a different angle.