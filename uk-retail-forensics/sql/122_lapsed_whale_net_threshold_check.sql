-- Query 122_lapsed_whale_net_threshold_check
-- WHAT: For customers in the most-lapsed recency quartile (quartile 4),
--       find the monetary_net value at the boundary between quartile 3
--       and quartile 4 (monetary) -- i.e. the actual cutoff that defines
--       the confirmed 59-customer lapsed-whale population from query 115
--       -- plus the min/max monetary_net within that population, to
--       replace an arbitrary round-number guess with the real boundary.
-- WHY: Building the Chapter Four "Funnel Tier" calculated field in
--      Tableau requires a monetary_net threshold to flag "Lapsed Whale"
--      status. An arbitrary £5,000 guess was proposed but not checked
--      against the data -- per this project's standing rule, this
--      replaces the guess with the actual boundary already established
--      in query 115's quartile crosstab.

WITH quartiled AS (
    SELECT
        customer_id,
        recency_days,
        monetary_net,
        NTILE(4) OVER (ORDER BY recency_days) AS recency_quartile,
        NTILE(4) OVER (ORDER BY monetary_net) AS monetary_quartile
    FROM uk_retail.customer_behavior_fields
    WHERE recency_days IS NOT NULL AND monetary_net IS NOT NULL
)
SELECT
    MIN(monetary_net) FILTER (WHERE monetary_quartile = 4) AS whale_threshold_min,
    MAX(monetary_net) FILTER (WHERE monetary_quartile = 4) AS whale_pool_max,
    MAX(monetary_net) FILTER (WHERE monetary_quartile = 3) AS just_below_threshold,
    COUNT(*) FILTER (WHERE recency_quartile = 4 AND monetary_quartile = 4) AS lapsed_whale_count
FROM quartiled
WHERE recency_quartile = 4;

-- RESULT (run July 18, 2026):
-- Within the most-lapsed recency quartile: monetary quartile 4 (the
-- lapsed-whale population) begins at £2,180.28 net and ranges up to
-- £30,375.26. Monetary quartile 3's maximum (just below the threshold)
-- is £2,154.08 -- a tight, clean boundary. Confirmed lapsed_whale_count
-- of 59, matching query 115 exactly.
--
-- CONFIRMED FINDING: The actual monetary_net threshold defining the
-- confirmed lapsed-whale population is £2,180.28, substantially lower
-- than the arbitrary £5,000 guess proposed for the Chapter Four Tableau
-- "Funnel Tier" calculated field. Using £5,000 would have excluded a real
-- portion of the confirmed 59-customer population (anyone spending
-- £2,180-£4,999 net) from the "Lapsed Whale" tier. The Tableau field
-- should use £2,180 (or £2,180.28 for precision) as the threshold instead.
--
-- [CROSS-REFERENCE — added following Query 127_whale_definition_
-- discrepancy_check, run July 18, 2026: this £2,180.28 threshold, used
-- together with query 123's 377-day recency threshold as a simple dual-
-- threshold definition, yields 58 customers (query 126), not the 59
-- reported here. Query 127 identified this gap as an NTILE tie-breaking
-- non-determinism issue (see the revision notice on queries 106 and 115),
-- not an error in this query. The 58-customer dual-threshold definition
-- was adopted as the standard going forward for Chapter Four -- this
-- query's threshold value remains correct and unchanged.]