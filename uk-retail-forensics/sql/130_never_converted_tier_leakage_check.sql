-- Query 130_never_converted_tier_leakage_check
-- WHAT: Split the 23 never-converted customers (frequency_completed IS
--       NULL AND monetary_gross IS NULL) by whether recency_days is
--       <= 377 or > 377, to confirm exactly how many fall on each side
--       of the Tableau "Recency-Monetary Tier" field's first IF branch.
-- WHY: The Tableau field's Recent/Lapsed-Typical/Lapsed-Whale counts
--      (4,408 / 1,409 / 58, total 5,875) don't match a direct SQL
--      reconstruction using the same thresholds on the 5,852-customer
--      population that excludes null monetary_net (4,407 / 1,387 / 58,
--      total 5,852) -- a gap of exactly 23. Since monetary_net is NULL
--      for the 23 never-converted customers, and Tableau's ELSEIF
--      condition on a NULL value silently evaluates as false rather
--      than erroring, those 23 customers are falling through to
--      whichever tier is reached based on recency_days alone -- meaning
--      they are being silently mislabeled as "Recent" or "Lapsed,
--      Typical" rather than excluded or flagged separately.

SELECT
    CASE WHEN recency_days <= 377 THEN 'Recency <= 377 (falls to Recent)'
         ELSE 'Recency > 377 (falls to Lapsed, Typical)' END AS tableau_fallthrough_tier,
    COUNT(*) AS customer_count
FROM uk_retail.customer_behavior_fields
WHERE frequency_completed IS NULL AND monetary_gross IS NULL
GROUP BY 1;

-- RESULT (run July 19, 2026):
-- Recency <= 377 (falls to Recent): 1 customer
-- Recency > 377 (falls to Lapsed, Typical): 22 customers
-- Exact match to the predicted split (4,407+1=4,408 Recent;
-- 1,387+22=1,409 Lapsed Typical), confirming all 23 never-converted
-- customers are being silently absorbed into the wrong tiers.
--
-- CONFIRMED FINDING: The Tableau "Recency-Monetary Tier (Rev.
-- Q105/106/122)" field mislabels all 23 never-converted customers
-- (query 98) as either "Recent" (1 customer) or "Lapsed, Typical" (22
-- customers), because monetary_net is NULL for this group and Tableau's
-- ELSEIF condition silently evaluates a NULL comparison as false rather
-- than erroring, causing fallthrough to the ELSE branch based on
-- recency_days alone. FIX: add an explicit ISNULL check as the first
-- condition in the field, giving never-converted customers their own
-- honest "Never Converted" label instead of a mislabeled tier --
-- IF ISNULL([Spend (Net)]) THEN "Never Converted" ELSEIF [Recency Days]
-- <= 377 THEN "Recent" ELSEIF ... (unchanged) ... END. This also means
-- the "Lapsed, Typical" 3D exhibit should be built from the corrected
-- 1,387-customer population, not the field's current (mislabeled)
-- 1,409-customer count.