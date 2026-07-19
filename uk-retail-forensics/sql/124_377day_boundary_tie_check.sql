-- Query 124_377day_boundary_tie_check
-- WHAT: Pull every customer with recency_days = 377 exactly, along with
--       their monetary_net and which quartile SQL's NTILE assigned them
--       to, to diagnose why Tableau's "Recency-Monetary Tier (Rev.
--       Q105/106/122)" field returns 58 lapsed whales instead of the
--       59 confirmed in queries 115 and 122.
-- WHY: Query 123 found a tie at the exact 377-day boundary (recency
--      quartile 3's max and quartile 4's min both equal 377), meaning
--      NTILE split same-value customers across both quartiles. The
--      Tableau field uses a strict "> 377" condition, which would
--      exclude ALL customers at exactly 377 days -- including any that
--      SQL had counted toward quartile 4. This checks whether that's
--      the actual source of the one-count discrepancy.

WITH quartiled AS (
    SELECT
        customer_id,
        recency_days,
        monetary_net,
        NTILE(4) OVER (ORDER BY recency_days) AS recency_quartile
    FROM uk_retail.customer_behavior_fields
    WHERE recency_days IS NOT NULL AND monetary_net IS NOT NULL
)
SELECT
    customer_id,
    recency_days,
    monetary_net,
    recency_quartile
FROM quartiled
WHERE recency_days = 377
ORDER BY monetary_net DESC;

-- RESULT (run July 18, 2026):
-- Four customers sit at exactly 377 days recency, all assigned to
-- recency_quartile 4 by SQL's NTILE:
--   16254: monetary_net £967.44
--   13891: monetary_net £859.21
--   17952: monetary_net £788.46
--   15914: monetary_net £205.99
-- None of these four have monetary_net anywhere close to the £2,180.28
-- whale threshold (query 122) -- all are well below it.
--
-- CONFIRMED FINDING: The 377-day recency boundary tie is NOT the source
-- of Tableau's 58-vs-59 discrepancy. None of the tied customers qualify
-- as lapsed whales regardless of whether the Tableau formula uses ">377"
-- or ">=377" -- their monetary_net values are far too low. This
-- hypothesis is ruled out. See Query 125 for the next candidate
-- explanation (floating-point precision at the £2,180.28 monetary
-- threshold).