-- Query 110_decile8_high_frequency_outlier_check
-- WHAT: Identify the customer(s) driving decile 8's anomalous MAX
--       frequency_completed of 100 (query 108), by pulling full
--       customer-level detail for the monetary_gross range covered by
--       decile 8, ordered by frequency descending, and confirming whether
--       this is a single outlier or a small cluster.
-- WHY: Query 108's decile crosstab showed decile 8 (70th-80th percentile
--      by spend) with a MAX frequency of 100 -- higher than decile 9's
--      MAX of 34, breaking the otherwise-clean ascending pattern across
--      deciles. Confirmed as a distinct outlier from customers 17850 and
--      12346 (query 109), since neither falls in this spend range. Per
--      this project's standing rule, the outlier needs to be identified
--      and characterized before being written up as a finding.

WITH decile AS (
    SELECT
        customer_id,
        recency_days,
        monetary_gross,
        frequency_completed,
        cancellation_count,
        order_return_rate_pct,
        NTILE(10) OVER (ORDER BY monetary_gross) AS monetary_decile
    FROM uk_retail.customer_behavior_fields
    WHERE monetary_gross IS NOT NULL AND frequency_completed IS NOT NULL
)
SELECT
    customer_id,
    recency_days,
    monetary_gross,
    frequency_completed,
    cancellation_count,
    order_return_rate_pct
FROM decile
WHERE monetary_decile = 8
ORDER BY frequency_completed DESC;

-- RESULT (run July 18, 2026):
-- The decile 8 outlier (MAX frequency 100) is customer 17961: recency 20
-- days, monetary_gross £2,866.74, 100 completed orders, 2 cancellations,
-- 2.0% order_return_rate_pct. This is NOT a new outlier -- it is the same
-- customer 17961 already identified and investigated in Chapter Three
-- (surfaced via 3D chart hover, rank 4673 by monetary_gross, flagged for
-- a disproportionately low average order value relative to peers at that
-- spend rank) and documented as closed/resolved in the project handoff:
-- "resolved as a recurring small retailer."
-- No second comparable outlier appears in the remainder of decile 8 --
-- frequency decays smoothly after 17961 (25, 22, 20, 20, 20, ...) with no
-- further anomalous spike.
--
-- CONFIRMED FINDING: The decile-8 frequency outlier flagged in query 108
-- is fully explained by customer 17961, a previously investigated and
-- closed Chapter Three finding, not a new pattern. No further follow-up
-- required. This cross-chapter consistency (the same customer surfacing
-- independently via chart rotation in Chapter Three and via decile
-- crosstab in Chapter Four prep) supports confidence in both findings.