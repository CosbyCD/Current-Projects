-- Query 109_lockstep_funnel_outlier_overlap_check
-- WHAT: Pull full customer-level detail (recency, frequency, monetary,
--       plus recency and monetary quartile) for every customer in the
--       300-349 day recency bucket, to test whether the frequency spike
--       found in query 107 (MAX 155 orders) and the monetary spike found
--       in query 105 (MAX £77,352.96) in that same bucket are driven by
--       the same customer(s), and whether either overlaps with the 61
--       "lapsed whale" customers identified in query 106 (recency
--       quartile 4, monetary quartile 4).
-- WHY: Query 105 (monetary) and query 107 (frequency) both showed an
--      anomalous spike in the identical 300-349 day recency bucket, right
--      next to the confirmed 618-customer seasonal cohort (350-424 days,
--      queries 100-101). Two very different behavioral signatures sitting
--      adjacent on the recency axis is worth verifying directly rather
--      than assuming a coincidence or assuming the two spikes are the
--      same population without checking.

WITH quartiled AS (
    SELECT
        customer_id,
        recency_days,
        frequency_completed,
        monetary_gross,
        NTILE(4) OVER (ORDER BY recency_days) AS recency_quartile,
        NTILE(4) OVER (ORDER BY monetary_gross) AS monetary_quartile
    FROM uk_retail.customer_behavior_fields
    WHERE recency_days IS NOT NULL AND monetary_gross IS NOT NULL
)
SELECT
    customer_id,
    recency_days,
    frequency_completed,
    monetary_gross,
    recency_quartile,
    monetary_quartile,
    CASE WHEN recency_quartile = 4 AND monetary_quartile = 4
         THEN 'lapsed_whale' ELSE NULL END AS lapsed_whale_flag
FROM quartiled
WHERE recency_days BETWEEN 300 AND 349
ORDER BY frequency_completed DESC, monetary_gross DESC;

-- RESULT (run July 18, 2026):
-- The 300-349 day bucket contains 136 customers, all in recency_quartile 3
-- (not 4) -- meaning this bucket is NOT part of the most-lapsed quartile
-- overall; it only appeared anomalous because it sits adjacent to the
-- confirmed 618-customer seasonal cohort (350-424 days).
-- The query 107 frequency spike (MAX 155) and the query 105 monetary
-- spike (MAX £77,352.96) are traced to two DIFFERENT customers, not one:
--   - customer 17850: recency 301 days, 155 orders, £51,208.87 monetary,
--     monetary_quartile 4 -- a genuine high-frequency buyer who also
--     carries high spend.
--   - customer 12346: recency 325 days, only 3 orders, £77,352.96
--     monetary, monetary_quartile 4 -- a low-frequency, very-high-ticket
--     buyer (likely one or two large orders), nearly the opposite profile
--     from 17850.
-- Neither customer is flagged lapsed_whale (recency_quartile 4 AND
-- monetary_quartile 4) -- both sit in recency_quartile 3.
--
-- CONFIRMED FINDING: The same-customer speculation recorded in query 107
-- was tested directly and disproved. The 300-349 day bucket's frequency
-- and monetary spikes are driven by two unrelated single-customer
-- outliers with opposite behavioral profiles (high-frequency vs.
-- high-ticket-low-frequency), not a shared population, and neither
-- overlaps with the 61 lapsed-whale customers from query 106. This is a
-- genuine methodological catch: an aggregate MAX spike in two separate
-- metrics landing in the same bucket does not imply a shared population
-- driving both -- that assumption required verification, not inference.