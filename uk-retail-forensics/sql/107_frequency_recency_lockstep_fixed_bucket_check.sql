-- Query 107_frequency_recency_lockstep_fixed_bucket_check
-- WHAT: Bin customers by recency_days into fixed 50-day buckets (matching
--       query 105's bucketing exactly), and show MAX and AVG
--       frequency_completed per bucket, to test whether high-frequency
--       customers are confined to low-recency buckets the same way
--       monetary value was tested in query 105.
-- WHY: Chapter Three's rotating 3D chart suggested a "frequency-monetary
--      lockstep" — high frequency is almost entirely confined to low
--      recency, described as three variables telling one story rather
--      than three independent signals. Per this project's standing rule
--      (visualization suggests, SQL confirms), this claim had not yet been
--      run through a query. Using the same 50-day buckets as query 105
--      allows direct side-by-side comparison of the monetary funnel and
--      the frequency pattern across identical recency windows.

SELECT
    (recency_days / 50) * 50 AS recency_bucket_start,
    (recency_days / 50) * 50 + 49 AS recency_bucket_end,
    COUNT(*) AS customer_count,
    MAX(frequency_completed) AS max_frequency_completed,
    AVG(frequency_completed) AS avg_frequency_completed
FROM uk_retail.customer_behavior_fields
WHERE recency_days IS NOT NULL  -- excludes the 23 never-converted customers
GROUP BY (recency_days / 50)
ORDER BY recency_bucket_start;

-- RESULT (run July 18, 2026):
-- AVG frequency_completed decays steadily with recency (10.95 -> 5.11 ->
-- 4.91 -> 4.38 -> 3.35 -> 2.85 -> ... -> 1.06 across the full range),
-- confirming the lockstep pattern holds for the typical customer, tracking
-- the same shape as monetary_gross did in query 105.
-- MAX frequency_completed spikes sharply to 155 at 300-349 days, in the
-- identical recency bucket where query 105's MAX monetary_gross also
-- spiked (to £77,352.96). This bucket sits directly adjacent to the
-- confirmed 618-customer seasonal cohort (350-424 days, queries 100-101).
--
-- SPECULATIVE READ (recorded as-stated, before verification): given that
-- both the frequency and monetary spikes land in the exact same 50-day
-- bucket, it seemed likely these were driven by the same customer(s) --
-- e.g. a heavy, established buyer who went dormant, appearing as an
-- outlier on both axes at once. Flagged as needing a direct customer-level
-- cross-check (see query 109) before treating that assumption as fact, per
-- this project's standing rule that a plausible read is not a confirmed
-- finding until run through SQL.
--
-- CONFIRMED FINDING: Average customer frequency declines steadily as
-- recency increases (lockstep with the monetary funnel), but the 300-349
-- day MAX spike is NOT the same customer(s) driving query 105's monetary
-- spike -- see query 109, which disproved the same-customer speculation
-- above and found two unrelated single-customer outliers instead.