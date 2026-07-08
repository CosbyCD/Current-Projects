-- ============================================================
-- FINDING: Negative quantity + blank description — full list
-- WHAT: Every row where quantity is negative AND description
--       is NULL or blank/whitespace.
-- WHY: Query 06 found one example (15044B, invoice 556012)
--      with a -27 quantity row, no description, no customer_id,
--      and a zero price — distinct from a genuine 'C'-prefix
--      cancellation on the same product. This checks whether
--      that pattern was isolated or widespread across the
--      full dataset.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE quantity < 0
AND (description IS NULL OR TRIM(description) = '')
ORDER BY invoice_date;