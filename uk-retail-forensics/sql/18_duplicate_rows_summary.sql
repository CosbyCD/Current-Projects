-- Query 18_duplicate_rows_summary

-- ============================================================
-- SUPPORTING CHECK: Duplicate rows — summary scale
-- WHAT: Counts how many distinct duplicate groups exist, and
--       the total number of excess rows (rows beyond the first
--       occurrence of each duplicate set) across the dataset.
-- WHY: Query 17 found individual duplicate groups repeating up
--      to 20 times. This quantifies the total scale of the
--      problem before deciding on a deduplication rule for the
--      clean table.
-- ============================================================
SELECT
    COUNT(*) AS duplicate_groups,
    SUM(duplicate_count - 1) AS excess_rows
FROM (
    SELECT COUNT(*) AS duplicate_count
    FROM uk_retail.raw_transactions
    GROUP BY invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
    HAVING COUNT(*) > 1
) sub;

-- RESULT: duplicate_groups = 32,907; excess_rows = 34,335. 32,907
-- distinct row combinations have at least one duplicate; removing all
-- duplication down to one row per group would eliminate 34,335 total
-- rows from raw_transactions (1,067,371 rows, so roughly 3.2% of the
-- entire dataset). The excess_rows count exceeding duplicate_groups by
-- only ~1,400 confirms most duplicate groups repeat just once extra
-- (duplicate_count = 2), consistent with Query 17's finding that the
-- 20x-repeated row (invoice 555524) is a rare high-end outlier, not
-- representative of the typical case.

-- CONFIRMED FINDING: The exact-duplicate-row problem affects
-- approximately 3.2% of the full raw dataset (34,335 of 1,067,371 rows)
-- — a real, non-trivial scale that would measurably inflate quantity and
-- monetary totals if left uncorrected, but not so large as to suggest a
-- systemic table-wide export failure (the vast majority of rows, ~96.8%,
-- are unique). Deduplication logic (collapsing each of the 32,907 groups
-- to a single row) is confirmed necessary before building clean_
-- transactions, and the scale here is now precisely quantified for that
-- step rather than left as an open question. This closes the exact-
-- duplicate investigation opened in Query 06 and expanded in Query 17 —
-- the pattern, its scale, and its likely source-side origin (whole
-- invoices duplicated together) are all now documented and ready for
-- the deduplication rule to be built.