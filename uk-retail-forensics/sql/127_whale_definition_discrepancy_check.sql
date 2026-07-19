-- Query 127_whale_definition_discrepancy_check
-- WHAT: Find the customer(s) who belong to the NTILE quartile-based
--       lapsed-whale group (recency_quartile=4 AND monetary_quartile=4,
--       as originally defined in queries 106/115) but do NOT satisfy the
--       simple dual-threshold definition (recency_days >= 377 AND
--       monetary_net >= 2180.28, used in queries 122/126 and the
--       Tableau field) -- explaining the 59-vs-58 discrepancy found
--       between the two independently-derived definitions.
-- WHY: Query 126's simple-threshold reconstruction returned 58 customers,
--      not the 59 confirmed via NTILE quartile crosstab in queries
--      106/115/122. Per this project's standing rule (when two
--      independently-derived results disagree, find the source rather
--      than average/reconcile), this identifies exactly which customer
--      and why, rather than accepting either count without
--      understanding the gap.

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
    customer_id,
    recency_days,
    monetary_net,
    recency_quartile,
    monetary_quartile
FROM quartiled
WHERE recency_quartile = 4
  AND monetary_quartile = 4
  AND NOT (recency_days >= 377 AND monetary_net >= 2180.28);

-- RESULT (run July 18, 2026):
-- One customer found: 13542, recency_days = 376, monetary_net £3,924.09,
-- recency_quartile 4, monetary_quartile 4.
-- This customer's recency (376) is BELOW the 377-day minimum that query
-- 123 established for recency_quartile 4 -- a direct contradiction from
-- the same NTILE logic run at a different time.
--
-- CONFIRMED FINDING: This is not a boundary-tie edge case -- it is
-- evidence that NTILE(4) OVER (ORDER BY recency_days), as used throughout
-- queries 106, 115, 122, and 123, is NON-DETERMINISTIC when ties exist at
-- the partition boundary. PostgreSQL does not guarantee stable ordering
-- for rows with equal values in the ORDER BY clause unless a secondary
-- tiebreaker column is specified. This means the exact quartile
-- boundaries and membership reported in queries 106, 115, 122, and 123
-- may not be perfectly reproducible if rerun -- a genuine methodological
-- gap in queries that were treated as fixed reference points for several
-- subsequent queries this session.
-- DECISION: rather than add a tiebreaker and rerun the full NTILE chain
-- to chase exact reproducibility, the simple dual-threshold definition
-- (recency_days >= 377 AND monetary_net >= 2180.28, yielding 58
-- customers, queries 122/126) is adopted as the standard "lapsed whale"
-- definition for Chapter Four going forward. It is fully deterministic,
-- reproducible on every run, and more easily explained to a stakeholder
-- than a population-quartile intersection. The NTILE-based 59-count
-- remains documented as the original discovery mechanism (queries
-- 106/115) but is superseded by the fixed-threshold definition for all
-- production/dashboard use. See the investigation log for the formal
-- revision notation on queries 106, 115, 122, and 123.