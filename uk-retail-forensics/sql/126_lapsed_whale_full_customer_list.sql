-- Query 126_lapsed_whale_full_customer_list
-- WHAT: List all 59 customer IDs in the confirmed lapsed-whale population
--       (recency_days >= 377 AND monetary_net >= 2180.28), sorted by
--       customer_id, to directly compare against Tableau's 58-count and
--       identify exactly which customer is missing.
-- WHY: Query 125 identified customer 15476 as sitting exactly at the
--      £2,180.28 threshold and a likely floating-point suspect, but
--      isolating that customer directly in Tableau showed it correctly
--      tagged as "Lapsed Whale" -- ruling out that specific hypothesis
--      too. Rather than continue guessing at causes, this pulls the full
--      ground-truth list so it can be compared row-by-row against what
--      Tableau actually shows, the same approach used throughout this
--      verification pass.

SELECT
    customer_id,
    recency_days,
    monetary_net
FROM uk_retail.customer_behavior_fields
WHERE recency_days >= 377
  AND monetary_net >= 2180.28
ORDER BY customer_id;

-- RESULT (run July 18, 2026):
-- The simple dual-threshold query (recency_days >= 377 AND monetary_net
-- >= 2180.28) returns 58 customers, NOT the 59 confirmed via NTILE
-- quartile crosstab in queries 106/115/122.
--
-- CONFIRMED FINDING: Tableau's "Recency-Monetary Tier (Rev.
-- Q105/106/122)" field returning 58 lapsed whales is NOT a Tableau bug.
-- The simple fixed-threshold reconstruction of the lapsed-whale
-- population genuinely produces 58, not 59, when tested directly in SQL.
-- The 59-count from queries 106/115/122 is a NTILE quartile-based
-- definition, which is not mathematically identical to a simple dual-
-- threshold definition whenever ties exist at a boundary value -- NTILE
-- can place a tied customer into quartile 4 without that customer
-- strictly satisfying both simple thresholds at once. See Query 127 for
-- identification of the specific customer causing this gap.