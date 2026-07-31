-- Query 164_stock_dead_stock_candidates_total_count

-- WHAT: Total count of SKUs matching Query 163's dead-stock threshold
--       (recency_days >= 377 AND frequency_completed <= 3), plus the
--       maximum distinct_customers value across that full population.
-- WHY: A recommendation about gift/bonus-offer candidates vs. plain
--      write-off candidates needs the actual population size and shape
--      before being written up, not just a 30-row sample.

SELECT
    COUNT(*) AS total_dead_stock_candidates,
    MAX(distinct_customers) AS max_distinct_customers,
    SUM(monetary_net) AS total_historical_net_value
FROM uk_retail.stock_behavior_fields
WHERE recency_days >= 377
  AND frequency_completed IS NOT NULL
  AND frequency_completed <= 3;

-- RESULT (verified against pasted output): 201 total candidates,
-- MAX(distinct_customers) = 3, total historical net value £14,025.45.
-- The max-3 figure is NOT a genuine finding about the population's
-- shape -- it's a structural artifact of Query 163's own filter.
-- distinct_customers can never exceed frequency_completed in this
-- dataset (each completed order ties to at most one customer), so
-- WHERE frequency_completed <= 3 mathematically guarantees
-- distinct_customers <= 3 for every matching row, before any actual
-- data is examined. The broad-appeal-vs-narrow-interest distinction
-- this query set out to test cannot be answered by this query as
-- designed -- it would require decoupling CURRENT dormancy from TOTAL
-- LIFETIME frequency (e.g. SKUs with high historical distinct_customers
-- that have since gone completely quiet), not filtering on low lifetime
-- frequency from the start.

-- CONFIRMED FINDING: 201 SKUs qualify as dead-stock candidates under
-- this threshold, representing a modest £14,025.45 in aggregate
-- historical value -- individually low-value (median well under £20
-- per SKU based on the top-30 slice), uniformly narrow-interest by
-- construction. Given the small aggregate value and structural
-- narrowness of this specific population, the practical recommendation
-- is a simple bundled gift-with-purchase clearance rather than a
-- differentiated broad-appeal marketing push -- there's no broad-appeal
-- subset within this definition to target differently. This closes
-- Phase 4's dead-stock angle within this sprint's deliberately narrow
-- scope; a genuinely different query (decoupling current dormancy from
-- historical popularity) would be needed to find a "was popular, now
-- dormant" subset, but is not pursued here, consistent with the petit
-- scope this sprint was scoped to.

-- [REVISION — added per Query 165_dead_stock_seasonality_check, run
-- July 22, 2026: the 201-SKU total and £14,025.45 aggregate value
-- reported here include 93 SKUs later found to be seasonal-only
-- (November/December-exclusive order history), not genuinely dead
-- inventory. The corrected clearance-candidate population is 108 SKUs,
-- not 201. The £14,025.45 aggregate figure should not be cited without
-- this caveat, since it includes seasonal items that will sell again.
-- See Query 165 for the full account and the revised recommendation.]
-- [FLAGGED] This query was likely run before stock_behavior_fields was
-- rebuilt against the corrected full_transactions. total_dead_stock_
-- candidates (COUNT(*), same WHERE clause as Query 163: recency_days
-- and frequency_completed only) and max_distinct_customers
-- (distinct_customers sources from clean_transactions, never touched by
-- the bug) are both structurally SAFE -- 201 and 3 are confirmed
-- correct with no rerun needed, consistent with Query 163's confirmed
-- population-membership result. total_historical_net_value is a
-- SUM(monetary_net) across the same 201-SKU population -- monetary_net
-- confirmed affected (Query 155) -- so this figure is stale and needs
-- an actual rerun to get the corrected aggregate. Given every displayed
-- monetary_net value in Query 163's top-30 corrected DOWNWARD (several
-- by exactly 50%), the corrected total is expected to be lower than
-- £14,025.45, not higher -- but the exact figure needs confirming, not
-- assumed.

-- [CONFIRMED via rerun against the rebuilt stock_behavior_fields]
-- Result: 201, 3, £13,352.35. total_dead_stock_candidates and
-- max_distinct_customers unchanged exactly as predicted (201, 3).
-- total_historical_net_value corrected downward from £14,025.45 to
-- £13,352.35 (-£673.10), consistent with the direction predicted from
-- Query 163's corrected top-30 values. This is the corrected aggregate
-- to cite going forward -- £14,025.45 reflects the pre-fix, inflated
-- figure and should not be used in any downstream reference
-- (storyboard, README, chapter_four_calculated_fields.md) from this
-- point on.