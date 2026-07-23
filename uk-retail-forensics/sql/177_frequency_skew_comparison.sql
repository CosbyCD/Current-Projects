-- Query 177_frequency_skew_comparison

-- WHAT: Compares the AVG-vs-MEDIAN gap for frequency_completed on both
--       the customer side (customer_behavior_fields) and the stock
--       side (Query 176's 572-SKU Overdue Restock population).
-- WHY: Direct candidate explanation for why the wave/spray shape
--      appears to echo across two otherwise-unrelated triads that
--      happen to share this one axis.

SELECT
    'Customer side (full population)' AS population,
    ROUND(AVG(frequency_completed)::NUMERIC, 2) AS avg_frequency,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY frequency_completed) AS median_frequency,
    MAX(frequency_completed) AS max_frequency
FROM uk_retail.customer_behavior_fields
WHERE frequency_completed IS NOT NULL

UNION ALL

SELECT
    'Stock side (Overdue Restock, 572 SKUs)',
    ROUND(AVG(frequency_completed)::NUMERIC, 2),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY frequency_completed),
    MAX(frequency_completed)
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed >= 5
  AND avg_interval_fractional_day IS NOT NULL
  AND recency_days >= 8 * avg_interval_fractional_day
  AND monetary_net >= 1000;

-- RESULT (verified against pasted output): Customer side -- avg 6.25,
-- median 3.0, max 373, ratio 2.08x. Stock side (Overdue Restock only)
-- -- avg 186.20, median 127.0, max 1383, ratio 1.47x. Both populations
-- show avg > median, confirming right-skew in both -- partial support
-- for the shared-axis-artifact theory. HOWEVER, this is not an
-- apples-to-apples comparison: the customer side is the FULL,
-- unfiltered population (matching what the original wave/spray
-- observation was based on), while the stock side is already filtered
-- to frequency_completed >= 5 AND monetary_net >= 1000 -- cutting off
-- the low-frequency tail before the comparison starts. A fair test
-- requires comparing against the FULL, unfiltered stock population
-- (all 4,734 SKUs), not the pre-selected Overdue Restock subset.

-- CONFIRMED FINDING: inconclusive as tested -- both populations skew
-- right, but the comparison's scope mismatch means this doesn't yet
-- confirm or rule out the shared-axis-artifact theory. See Query 178
-- for the corrected, full-population comparison.