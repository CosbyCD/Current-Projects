-- ============================================================
-- FOLLOW-UP: Zero-price rows WITH a customer_id — closest look
-- WHAT: Isolates the 89 rows that are zero-price, have a real
--       description, AND have a customer_id attached — these
--       are the only zero-price rows in this thread that would
--       directly affect a real customer's derived fields.
-- WHY: Of 1,511 zero-price rows outside excluded_rows, 1,422
--      have no customer_id (same unattributed pattern as
--      excluded_rows) and can reasonably be treated the same
--      way. The 89 WITH a customer_id are different — a zero
--      price on an attributed transaction could mean a
--      promotional/free item, a pricing error, or something
--      else worth seeing directly before deciding how to
--      handle it in the clean table.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions r
WHERE unit_price = 0
AND customer_id IS NOT NULL AND TRIM(customer_id) != ''
AND NOT EXISTS (
    SELECT 1 FROM uk_retail.excluded_rows e
    WHERE e.invoice_no = r.invoice_no
    AND e.stock_code = r.stock_code
    AND e.invoice_date = r.invoice_date
)
ORDER BY invoice_date;