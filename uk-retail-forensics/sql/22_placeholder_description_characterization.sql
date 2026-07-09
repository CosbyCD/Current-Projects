-- ============================================================
-- FOLLOW-UP: Placeholder description rows — characterization
-- WHAT: Checks whether the 327 placeholder-description rows
--       share other traits with earlier findings (zero price,
--       no customer_id, negative quantity) or are otherwise
--       normal transactions apart from the odd description.
-- WHY: Determines whether this is a new, independent category
--      or an extension of a pattern already found.
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_price,
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_qty,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS no_customer,
    COUNT(DISTINCT stock_code) AS distinct_stock_codes
FROM uk_retail.raw_transactions
WHERE description IN ('check', 'found', 'Check', 'Found', 'CHECK', 'FOUND', '?', 'missing', 'Missing', 'MISSING', 'lost', 'Lost', 'LOST');