-- Query 108_frequency_monetary_lockstep_decile_crosstab
-- WHAT: Bin customers by monetary_gross decile, and show the distribution
--       of frequency_completed per decile, to test the specific claim that
--       frequency "spikes sharply only in the top ~15-20% of customers by
--       spend."
-- WHY: Query 107 tests the lockstep pattern via recency buckets (mirroring
--      query 105's approach). This is the second, independently-derived
--      fork on the same finding — per the project's standing rule, both
--      are built and kept side by side rather than settling on one
--      threshold definition. Deciles (rather than quartiles, as used in
--      query 106) are used here specifically because the original visual
--      claim referenced a "top 15-20%" threshold, which quartiles (25%
--      bands) cannot resolve precisely — deciles let the 80th/85th
--      percentile boundary be checked directly.

WITH decile AS (
    SELECT
        customer_id,
        monetary_gross,
        frequency_completed,
        NTILE(10) OVER (ORDER BY monetary_gross) AS monetary_decile
    FROM uk_retail.customer_behavior_fields
    WHERE monetary_gross IS NOT NULL AND frequency_completed IS NOT NULL
)
SELECT
    monetary_decile,
    COUNT(*) AS customer_count,
    MIN(frequency_completed) AS min_frequency_completed,
    AVG(frequency_completed) AS avg_frequency_completed,
    MAX(frequency_completed) AS max_frequency_completed
FROM decile
GROUP BY monetary_decile
ORDER BY monetary_decile;

-- RESULT (run July 18, 2026):
-- AVG frequency_completed climbs gradually through most deciles: 1.12 ->
-- 1.38 -> 1.66 -> 2.23 -> 3.03 -> 3.75 -> 4.91 -> 7.37 -> 10.26 -> then
-- jumps sharply to 26.84 in decile 10. Decile 10's average is 2.6x decile
-- 9's -- not a smooth continuation of the gradual climb seen through
-- deciles 1-9.
-- Notably, decile 8's MAX frequency_completed is 100 -- higher than
-- decile 9's MAX of 34 -- a high-frequency outlier sitting in the 70-80th
-- percentile of spend, breaking the otherwise-clean ascending pattern.
-- This is a third, distinct outlier from customers 17850 and 12346
-- (identified in query 109), since neither of those would fall in
-- decile 8. Not yet investigated as of this query's close.
--
-- CONFIRMED FINDING (revised from Chapter Three's original visual
-- estimate of "top ~15-20%"): the frequency spike is real, but narrower
-- and sharper than originally eyeballed -- it is concentrated in the top
-- decile (90th+ percentile) by monetary spend, not the broader top
-- 15-20%. Combined with query 107, the frequency-monetary lockstep holds
-- directionally as a general tendency, but -- consistent with the funnel
-- finding in queries 105-106 -- the precise boundary only became clear
-- once verified against the data rather than estimated from the chart
-- rotation. A distinct, unexplained high-frequency outlier in decile 8
-- is flagged for follow-up investigation.