-- Query 14_full_column_completeness_check

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

-- RESULT: total_rows = 1,067,371. Six of eight columns are fully
-- populated with zero gaps: invoice_no, stock_code, quantity,
-- invoice_date, unit_price, and country all show 0 missing. Two columns
-- have real gaps: description is missing/blank in 4,382 rows (0.41%),
-- and customer_id is missing/blank in 243,007 rows (22.77%) — using the
-- correct TRIM(customer_id) = '' check this time, not just IS NULL.

-- CONFIRMED FINDING: This query resolves the open question flagged back
-- in Query 11, where "customer_id IS NOT NULL" alone let a blank-string
-- customer_id slip through and silently pool 8,752 orders under one
-- artificial "customer." Using TRIM(customer_id) = '' alongside the NULL
-- check here confirms the true scope: 243,007 rows (22.77% of the full
-- dataset) have no usable customer_id, whether from a genuine NULL or a
-- blank string. This is the authoritative count going forward — any
-- customer-level query built before this point (Queries 11-13,
-- specifically) used an incomplete filter and should be understood in
-- that light. Customer_id and description are the only two columns
-- requiring cleaning attention; the other six raw columns are
-- structurally complete and need no further gap-filling work. The
-- 243,007 no-customer-id rows are a known, large population — consistent
-- with this dataset's documented pattern of guest/unattributed retail
-- transactions — and will need their own dedicated handling path
-- (see later queries on unattributed_transactions, Query 96) separate
-- from the customer-behavior-fields build.