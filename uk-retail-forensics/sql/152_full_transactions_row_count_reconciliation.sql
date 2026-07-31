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

-- [REVISION] Both the RESULT block above ("matching full_transactions
-- exactly -- the UNION ALL is complete and correct, no rows lost") and
-- the CONFIRMED FINDING below are superseded. The raw numbers in RESULT
-- are accurate (1,022,517 + 228,297 = 1,250,814 is correct arithmetic),
-- but the interpretation drawn from that match -- in both blocks -- was
-- wrong. A matching sum doesn't prove a correct disjoint union; it can't
-- distinguish that from a duplicated one, because unattributed_
-- transactions is a subset COPY of clean_transactions (confirmed at
-- Query 96: "clean_transactions itself is left completely unchanged"
-- when the split was made), not a disjoint set. Row-level verification
-- at Queries 151b and 151c found that all 228,297 unattributed_
-- transactions rows are also embedded in clean_transactions and were
-- being counted twice -- something this query's aggregate-only check
-- could never surface. full_transactions' actual correct row count is
-- 1,022,517, not 1,250,814; the corrected build is Query 151d. Left
-- standing per the append-only rule: this is a genuine example of an
-- arithmetic check passing while the underlying data was still wrong --
-- exactly the gap this project's row-level-verification standard exists
-- to catch, and a useful documented instance of it doing so, one query
-- late.