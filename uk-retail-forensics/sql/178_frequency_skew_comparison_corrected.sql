-- Query 178_frequency_skew_comparison_corrected

-- WHAT: Re-runs Query 177's comparison using the FULL, unfiltered
--       stock population (all 4,734 SKUs), matching the scope of the
--       customer side's full population.
-- WHY: Query 177 compared the customer side's full population against
--      an already-filtered stock subset, which structurally guaranteed
--      a less extreme skew on the stock side regardless of the
--      underlying data. This corrects that mismatch.

SELECT
    'Customer side (full population)' AS population,
    ROUND(AVG(frequency_completed)::NUMERIC, 2) AS avg_frequency,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY frequency_completed) AS median_frequency,
    MAX(frequency_completed) AS max_frequency
FROM uk_retail.customer_behavior_fields
WHERE frequency_completed IS NOT NULL

UNION ALL

SELECT
    'Stock side (full population)',
    ROUND(AVG(frequency_completed)::NUMERIC, 2),
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY frequency_completed),
    MAX(frequency_completed)
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed IS NOT NULL;

-- RESULT (verified against pasted output): Customer side -- avg 6.25,
-- median 3.0, max 373, ratio 2.08x. Stock side -- avg 210.39, median
-- 89.0, max 5,471, ratio 2.36x. This is now a fair, apples-to-apples
-- comparison (both full, unfiltered populations). Skew ratios are
-- closely comparable, and the stock side is if anything MORE
-- right-skewed than the customer side (higher ratio, far higher
-- absolute max relative to its own median).

-- CONFIRMED FINDING: frequency_completed is independently, comparably
-- right-skewed on both the customer side and the stock side. This
-- supports the candidate explanation for the visual echo between the
-- Chapter Three customer cube and this sprint's Overdue Restock
-- exhibit: a field this heavily right-skewed will tend to produce a
-- dense-cluster-with-thinning-tail shape whenever plotted against
-- almost any second axis, regardless of what that second axis
-- measures or whether the two datasets have any deeper relationship.
-- The wave/spray-like shape observed in both charts is most likely a
-- shared statistical property of frequency_completed itself, not
-- independent evidence of a deeper structural connection between
-- customer behavior and stock behavior. This resolves the open visual
-- observation with an actual SQL-based explanation, per this project's
-- standard -- consistent with, and a natural extension of, this
-- project's earlier finding (Chapter Three) that average/median gaps
-- reliably signal a small number of extreme outliers driving apparent
-- structure.