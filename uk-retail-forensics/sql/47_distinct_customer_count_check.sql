-- Query 47_distinct_customer_count_check

-- ============================================================
-- VERIFICATION: Distinct customer count — baseline for recency check
-- WHAT: Counts the total number of distinct, non-null customer_id
--       values in clean_transactions.
-- WHY: Establishes the expected row count for the recency field
--      (query 45) — if recency has one row per customer, its
--      row count should match this number exactly. Query 46
--      first attempted this without DISTINCT and returned an
--      unusable transaction-level count; this is the corrected
--      version.
-- ============================================================
SELECT COUNT(DISTINCT customer_id) FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL;

-- RESULT: 5,941 distinct customers.

-- CONFIRMED FINDING: 5,941 distinct customers confirmed in
-- clean_transactions at this point in the project. Notably close to
-- the 5,942 unique customers reported in an independent academic
-- analysis of the full raw dataset (found during earlier verification
-- research, see Phase 6 external check) -- off by exactly one, directly
-- explained by the data-quality work done in Chapter One: the
-- unattributable customer 13256 outlier (Queries 28-31, excluded from
-- clean_transactions as a confirmed data entry error) is the clearest
-- single contributor to that gap. This establishes 5,941 as the
-- expected baseline row count for the recency field (Query 45) and any
-- other one-row-per-customer field built from this point forward.