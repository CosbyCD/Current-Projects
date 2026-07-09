-- ============================================================
-- FOLLOW-UP: Zero-price rows outside excluded_rows — characterization
-- WHAT: Of the 1,511 zero-price rows not already in excluded_rows,
--       checks whether they have real descriptions and customer_ids
--       attached, distinguishing genuine pricing errors on real
--       transactions from another variant of internal stock activity.
-- WHY: 73,468 of the 75,359 low-price rows found in query 26 are
--      plausibly legitimate low-cost merchandise (10-49p), not a
--      data quality issue. The 1,511 exact-zero rows warrant
--      closer inspection since zero price on an otherwise real
--      transaction is a stronger anomaly signal than simply "cheap."
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE description IS NOT NULL AND TRIM(description) != '') AS has_description,
    COUNT(*) FILTER (WHERE customer_id IS NOT NULL AND TRIM(customer_id) != '') AS has_customer_id,
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_qty,
    COUNT(*) FILTER (WHERE quantity > 0) AS positive_qty
FROM uk_retail.raw_transactions r
WHERE unit_price = 0
AND NOT EXISTS (
    SELECT 1 FROM uk_retail.excluded_rows e
    WHERE e.invoice_no = r.invoice_no
    AND e.stock_code = r.stock_code
    AND e.invoice_date = r.invoice_date
);