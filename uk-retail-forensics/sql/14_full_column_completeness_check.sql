-- ============================================================
-- AUDIT: Full column completeness check
-- WHAT: Checks every one of the 8 raw columns for NULL values
--       and blank/whitespace-only strings, so every gap in the
--       dataset is identified before building the clean table.
-- WHY: Before deriving the six customer behavior fields, every
--      record going into the clean dataset needs to be fully
--      populated. This surfaces every column's gap count in
--      one pass for direct comparison.
-- ============================================================
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE invoice_no IS NULL OR TRIM(invoice_no) = '') AS missing_invoice_no,
    COUNT(*) FILTER (WHERE stock_code IS NULL OR TRIM(stock_code) = '') AS missing_stock_code,
    COUNT(*) FILTER (WHERE description IS NULL OR TRIM(description) = '') AS missing_description,
    COUNT(*) FILTER (WHERE quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE invoice_date IS NULL) AS missing_invoice_date,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS missing_unit_price,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS missing_customer_id,
    COUNT(*) FILTER (WHERE country IS NULL OR TRIM(country) = '') AS missing_country
FROM uk_retail.raw_transactions;