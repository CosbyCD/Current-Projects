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
-- Phase 5 headline exhibit, alongside Query 164/165's Dead Stock (108)
-- and Seasonal Dormant (93) figures.

-- [FLAGGED -- HIGH PRIORITY, genuinely different from every other
-- headline query in this chapter] This query was likely run before
-- stock_behavior_fields was rebuilt against the corrected
-- full_transactions. Unlike Queries 163/164/171 (where monetary_net
-- only appeared in ORDER BY or as a display/SUM column, never gating
-- population membership), THIS query uses monetary_net >= 1000 directly
-- in the WHERE clause as a population-selection filter. Since
-- monetary_net was confirmed INFLATED by the bug (Query 155), some SKUs
-- may have crossed the £1,000 floor on inflated pre-fix values that
-- would NOT cross it on corrected values -- meaning 572 itself, not
-- just its aggregate dollar figure, is at risk. Direction expectation:
-- the corrected count is more likely to be LOWER than 572 (since
-- inflation would have pushed more SKUs above the floor, not fewer),
-- but this is NOT reasoned safe and must not be treated as confirmed
-- until independently rerun. This is the single most important rerun
-- remaining in this entire investigation thread -- 572 is the headline
-- figure cited in README, storyboard, and chapter_four_calculated_
-- fields.md, and it is the one number in this whole chapter that could
-- still genuinely be wrong.

-- [CONFIRMED via rerun against the rebuilt stock_behavior_fields --
-- THE HEADLINE FIGURE ACTUALLY CHANGED] Result: 513, £1,973,816.36.
-- total_candidates dropped from 572 to 513 -- a real reduction of 59
-- SKUs (10.3%), exactly the risk flagged above: some SKUs crossed the
-- £1,000 monetary_net floor on inflated pre-fix values that do not
-- cross it on corrected values. total_historical_net_value corrected
-- from £2,328,688.20 to £1,973,816.36 (-£354,871.84).
--
-- THIS IS THE ONE HEADLINE FIGURE IN CHAPTER FIVE THAT GENUINELY
-- CHANGED. 93 (Seasonal Dormant) and 108 (Dead Stock) were both
-- confirmed unchanged; 513 (Overdue Restock, was 572) is the
-- correction. The category-size ratio noted in the original CONFIRMED
-- FINDING ("2.8x the size of the 201-SKU dead-stock category") should
-- be restated: 513 / 201 = 2.55x -- the qualitative point (overdue-
-- restock naturally outnumbers genuine dead stock) still holds, only
-- the exact ratio needed updating.
--
-- CORRECTED HEADLINE TRIO FOR CHAPTER FIVE: 513 Overdue Restock / 93
-- Seasonal Dormant / 108 Dead Stock -- NOT 572/93/108. This supersedes
-- every prior citation of 572 across this project's documentation
-- (README.md, storyboard_spine, chapter_four_calculated_fields.md,
-- investigation_log.md's Chapter Five section) -- all four need this
-- correction applied.