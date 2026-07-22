-- Query 39_clean_transactions_row_count_reconciliation

-- ============================================================
-- VERIFICATION: clean_transactions row count — reconciliation
-- WHAT: Checks the actual clean_transactions row count against
--       a naive subtraction estimate, and — if a discrepancy
--       exists — investigates whether excluded_rows itself
--       contains internal exact-duplicate entries that would
--       explain it.
-- WHY: Query 38 produced 1,028,437 rows, 111 more than the naive
--      estimate (1,067,371 - 34,335 - 4,709 - 1 = 1,028,326).
--      Per this project's standing rule, a discrepancy gets
--      explained before the table is trusted, not waved off as
--      harmless.
-- ============================================================
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date)) AS distinct_rows
FROM uk_retail.excluded_rows;

-- RESULT: excluded_rows contains 4,709 total rows but only 4,598
-- DISTINCT rows -- confirming excluded_rows itself contains 111
-- internal exact-duplicate pairs. This is the exact number needed to
-- account for the discrepancy: 4,709 - 4,598 = 111, matching Query
-- 38's gap precisely.

-- CONFIRMED FINDING: The 111-row discrepancy is fully and exactly
-- explained. excluded_rows was built in Query 24 by copying rows
-- directly from raw_transactions BEFORE the deduplication policy was
-- finalized in Queries 36-38 -- meaning it was never itself
-- deduplicated, and inherited some of the same exact-duplicate rows
-- already characterized in Queries 17-18. In Query 38's build, the
-- `deduplicated` CTE runs FIRST, collapsing raw_transactions down to
-- one copy per unique row -- including collapsing what would have been
-- 111 duplicate pairs among the rows later matched against
-- excluded_rows. By the time the exclusion filter ran, those 111 extra
-- copies were already gone, so the exclusion step had fewer actual
-- rows available to remove than the raw 4,709 count implied. The
-- duplicate-row problem (Queries 17-18) and the internal-stock-activity
-- problem (Phase 6, Threads 1-3) turned out to be partially entangled
-- in a way no prior query explicitly tested -- and the build handled
-- the overlap correctly by construction, without needing a special
-- case or a fix. clean_transactions at 1,028,437 rows is confirmed
-- fully reconciled and trustworthy. This closes the Chapter One build
-- verification thread (36-39).