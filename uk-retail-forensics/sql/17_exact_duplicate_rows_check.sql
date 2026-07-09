-- ============================================================
-- INVESTIGATION: Exact duplicate rows — dataset-wide check
-- WHAT: Finds rows that are fully identical across every column
--       (invoice_no, stock_code, description, quantity,
--       unit_price, customer_id, invoice_date) appearing more
--       than once in the raw table.
-- WHY: Noticed in query 06's output that three invoices on
--      stock code 15044B (536525, 537405, 537434) each appeared
--      as fully identical duplicate lines. Checking whether this
--      was isolated to that one product or a broader pattern
--      across the dataset — duplicate rows would inflate
--      quantity and monetary totals in the derived fields if
--      left uncorrected.
-- ============================================================
SELECT
    invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date,
    COUNT(*) AS duplicate_count
FROM uk_retail.raw_transactions
GROUP BY invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;