-- ============================================================
-- VERIFICATION: clean_transactions — row count reconciliation
-- WHAT: Checks whether any excluded_rows entries were also
--       exact duplicates of each other, which would explain
--       why the actual clean_transactions row count (1,028,437)
--       differs slightly from the naive subtraction estimate
--       (1,028,326).
-- WHY: Before trusting clean_transactions, confirming the
--      111-row discrepancy has a legitimate explanation rather
--      than indicating something went wrong in the build.
-- ============================================================
SELECT COUNT(*) AS excluded_rows_total,
       COUNT(DISTINCT (invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date)) AS excluded_rows_distinct
FROM uk_retail.excluded_rows;