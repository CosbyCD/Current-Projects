-- ============================================================
-- INVESTIGATION: The remaining 1,693 blank-description rows
-- WHAT: Of the 4,382 total blank-description rows found in the
--       full column completeness audit (query 14), 2,689 were
--       already characterized as negative-qty/no-customer/
--       zero-price rows (Phase 3). This isolates the remaining
--       1,693 rows that do NOT fit that pattern, to see what
--       they actually look like.
-- WHY: A genuine gap identified in query 14 — never yet
--      investigated. Could be a different pattern entirely:
--      positive quantity, a real customer_id attached, or both.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE (description IS NULL OR TRIM(description) = '')
AND NOT (quantity < 0 AND (customer_id IS NULL OR TRIM(customer_id) = ''))
ORDER BY invoice_date;