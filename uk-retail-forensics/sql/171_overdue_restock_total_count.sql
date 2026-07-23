-- Query 171_overdue_restock_total_count

-- WHAT: Total count of SKUs matching Query 162's overdue-restock
--       threshold (frequency_completed >= 5, avg_interval_fractional_day
--       IS NOT NULL, recency_days >= 3x avg_interval_fractional_day) --
--       Query 162 only showed the top 30 by overdue_multiple, the same
--       gap Query 164 closed for the dead-stock population.
-- WHY: Needed before building the Phase 5 exhibit -- plotting only the
--      top 30 without knowing the true population size would misrepresent
--      the category's actual scale relative to the other two.

SELECT
    COUNT(*) AS total_overdue_restock_candidates,
    SUM(monetary_net) AS total_historical_net_value
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed >= 5
  AND avg_interval_fractional_day IS NOT NULL
  AND recency_days >= 3 * avg_interval_fractional_day;

-- RESULT (verified against pasted CSV): 1,532 SKUs -- 32.4% of the
-- full 4,734-SKU catalog -- total historical net value £3,313,963.00.
-- This threshold is far too loose to function as a targeted signal; a
-- 3x multiple flags routine order-timing variance for a genuine,
-- ongoing product, not genuine anomalous dormancy. The top-30 slice
-- originally reviewed at Query 162 was not representative of this
-- population -- it was the extreme tail of a much broader, largely
-- unremarkable group.

-- CONFIRMED FINDING: Query 162's 3x threshold requires tightening
-- before use in any exhibit or stakeholder-facing recommendation.
-- Candidates: raise the multiple substantially (e.g. 8-10x) and/or add
-- a historical value floor, so the flagged population is inherently
-- restricted to SKUs both meaningfully dormant AND worth purchasing's
-- attention. See Query 173 for the retightened threshold.