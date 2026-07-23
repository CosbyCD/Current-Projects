-- Query 152_full_transactions_row_count_reconciliation

-- WHAT: Directly re-counts both source tables independently, to
--       determine which one no longer matches its previously-verified
--       count and locate the source of the 5,920-row gap between the
--       expected total (1,256,734) and the actual full_transactions
--       result (1,250,814).
-- WHY: Per this project's standing rule, a discrepancy against a
--      naive expected count gets run down before the new table is
--      trusted, not assumed harmless.

SELECT 'clean_transactions' AS source_table, COUNT(*) AS row_count
FROM uk_retail.clean_transactions
UNION ALL
SELECT 'unattributed_transactions', COUNT(*)
FROM uk_retail.unattributed_transactions;

-- RESULT (verified against pasted CSV): clean_transactions = 1,022,517;
-- unattributed_transactions = 228,297. Sum = 1,250,814, matching
-- full_transactions exactly -- the UNION ALL is complete and correct,
-- no rows lost. The 5,920-row gap traces entirely to Query 151's WHY
-- block using a stale reference figure: 1,028,437 was clean_
-- transactions' row count immediately after its ORIGINAL build (Query
-- 38), before its two subsequent in-place amendments (Query 59's
-- admin-code exclusion, Query 74's stock code 23843 exclusion) each
-- removed more rows. 1,022,517 is the correct, current, fully-amended
-- count. This was an error in the retrofit's own stated expectation,
-- not a data-quality issue in full_transactions itself.

-- CONFIRMED FINDING: uk_retail.full_transactions (1,250,814 rows) is
-- verified correct and complete. The apparent discrepancy at Query 151
-- was caused by comparing against clean_transactions' pre-amendment row
-- count rather than its current one -- corrected here, no further
-- action needed. full_transactions is cleared for use in Phase 2.