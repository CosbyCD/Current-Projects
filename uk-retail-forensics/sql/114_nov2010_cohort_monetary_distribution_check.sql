-- Query 114_nov2010_cohort_monetary_distribution_check
-- WHAT: Pull the monetary_gross distribution (min, max, avg, and a
--       bucketed breakdown) for the confirmed 618-customer Nov 2010
--       cohort (recency_days BETWEEN 350 AND 424, per query 100), to
--       characterize whether their spend profile is consistent with
--       small one-off gift buyers or larger wholesale/stocking orders.
-- WHY: Query 101 characterized this cohort's frequency (91.5% placed 5
--      or fewer orders total) but never checked their monetary profile.
--      The working hypothesis (query 100) is that this cohort reflects
--      small wholesale/gift retailers stocking up ahead of the 2010
--      Christmas season. Low frequency alone doesn't distinguish a
--      one-time small gift buyer from a one-time large wholesale
--      stocking order -- monetary value does. This closes the remaining
--      gap in the cohort's characterization before it is finalized as a
--      Chapter Four Tableau bucket.

SELECT
    MIN(monetary_gross) AS min_monetary_gross,
    MAX(monetary_gross) AS max_monetary_gross,
    AVG(monetary_gross) AS avg_monetary_gross,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY monetary_gross) AS median_monetary_gross
FROM uk_retail.customer_behavior_fields
WHERE recency_days BETWEEN 350 AND 424;

-- RESULT (run July 18, 2026):
-- MIN monetary_gross: £10.95
-- MAX monetary_gross: £65,500.07
-- AVG monetary_gross: £913.76
-- MEDIAN monetary_gross: £468.08
-- The gap between average and median (913.76 vs 468.08) indicates a
-- right-skewed distribution -- most customers in this cohort spent
-- modestly, with a smaller number of high spenders pulling the average
-- up. See query 117 for the bucketed breakdown showing this shape
-- directly.
-- The MAX figure (£65,500.07) is the same value that surfaced as the
-- 350-399 day bucket's MAX monetary_gross in query 105, flagged there as
-- not yet investigated. This cohort (350-424 days recency) overlaps that
-- bucket range, so this is the same unexamined outlier resurfacing, not
-- a new one -- not yet confirmed as genuine spend vs. a cancelled-order
-- artifact (see query 111/112 precedent with customer 12346).
--
-- CONFIRMED FINDING: The Nov 2010 cohort's spend is right-skewed --
-- median £468.08 is consistent with modest small-shop gift/stocking
-- purchases, but the distribution has a real high-spend tail pulling the
-- mean up. See query 117 for the bucketed breakdown. The cohort's
-- £65,500.07 maximum is not yet confirmed as genuine and needs a
-- gross-vs-net check before being trusted -- that follow-up is next in
-- the queue after 115 and 116.