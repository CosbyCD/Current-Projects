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

-- RESULT (run July 18, 2026, verified against pasted CSV): 15 buckets,
-- 0-49 through 700-749, summing to 5,875 customers — NOT 5,852. As at
-- Query 99, the WHERE recency_days IS NOT NULL clause does not exclude
-- the 23 never-converted customers; it is a no-op on this table, since
-- recency_days carries no NULLs (only frequency_completed and
-- monetary_gross are NULL for those 23 customers). This is now a
-- recurring pattern across at least two queries (99, 105) and should be
-- checked for in any future query reusing this filter as a stated
-- exclusion mechanism. AVG monetary_gross decays steadily with recency,
-- from £5,544.9996... (0-49 bucket, rounds to 5,545) down to £260.85
-- (700-749 bucket, rounds to 261) — confirmed exactly against the CSV.
-- MAX monetary_gross does NOT funnel — it is erratic across the entire
-- range: the cited spikes at 300-349 (£77,352.96), 350-399 (£65,500.07),
-- and 600-649 (£34,023.26) all confirm exactly against the CSV. However,
-- the single largest value in the whole table — £580,987.04, in the
-- 0-49 bucket — was not mentioned in the original RESULT text, despite
-- being over 7x larger than any other bucket's max. Its omission doesn't
-- change the funnel conclusion (a zero-recency customer with high value
-- is expected, not anomalous), but it should have been included in an
-- "erratic across the entire range" characterization for completeness.

-- CONFIRMED FINDING (revised from Chapter Three's original visual claim):
-- Average customer spend declines steadily as recency increases, but a
-- small population of high-value outliers exists at every recency level,
-- including a £580,987.04 maximum in the most-recent bucket that the
-- original write-up omitted from its outlier list. The funnel governs the
-- typical customer; it does not govern the tail. Separately, this query's
-- WHERE recency_days IS NOT NULL clause does not exclude the 23
-- never-converted customers as commented — confirmed customer_count sums
-- to 5,875, not 5,852 — a repeat of the same no-op pattern first found at
-- Query 99. See query 106 for the independently-derived quartile-crosstab
-- fork, which confirms this same revised finding from a different angle.