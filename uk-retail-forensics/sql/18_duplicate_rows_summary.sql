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