-- Query 173_overdue_restock_retightened_threshold

-- WHAT: Retightens Query 162's overdue-restock definition: raises the
--       multiple from 3x to 8x (recency_days >= 8 * avg_interval_
--       fractional_day) and adds a £1,000 historical net value floor,
--       restricting the population to SKUs both meaningfully dormant
--       AND worth purchasing's attention.
-- WHY: Query 171 found the original 3x threshold flagged 1,532 SKUs
--      (32.4% of the catalog) -- too loose to function as a targeted
--      signal, capturing routine order-timing variance rather than
--      genuine anomalous dormancy. This tightens the definition before
--      it's used in the Phase 5 exhibit or any stakeholder-facing
--      recommendation.

SELECT
    COUNT(*) AS total_candidates,
    SUM(monetary_net) AS total_historical_net_value
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed >= 5
  AND avg_interval_fractional_day IS NOT NULL
  AND recency_days >= 8 * avg_interval_fractional_day
  AND monetary_net >= 1000;

-- RESULT (verified against pasted output): 572 candidates, £2,328,688.20
-- total historical net value -- 12.1% of the full 4,734-SKU catalog,
-- 2.8x the size of the 201-SKU dead-stock category. Retains £2.33M of
-- the original 3x threshold's £3.31M value, confirming the floor
-- primarily removed low-value noise rather than substantive candidates.

-- CONFIRMED FINDING: 572 is accepted as the final overdue-restock
-- population at this threshold. DECISION: the size asymmetry against
-- the 201-SKU dead-stock category is accepted as genuine, not
-- artificially rebalanced -- forcing equal-sized categories across the
-- exhibit would shape the threshold to fit the chart rather than let
-- the chart reflect what's actually true. It is not inherently
-- surprising that "overdue for restock" (a naturally larger category --
-- most catalog SKUs are viable, ongoing products that occasionally lag)
-- outnumbers "genuinely dead stock" (comparatively rare, true
-- abandonment). This is now the locked definition for Phase 5's
--