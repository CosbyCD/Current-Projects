-- ============================================================
-- FINDING: The remaining 1,693 blank-description rows —
--          characterized as stock movement / non-sale entries
-- WHAT: Confirms the shared traits of the 1,693 rows found in
--       query 15: positive quantity, zero unit_price, no
--       customer_id, and a high concentration on non-numeric
--       administrative stock codes (POST, DOT, C2, TEST002,
--       gift_0001_XX, DCGS-prefixed codes) as well as batch-
--       timestamped entries across many ordinary product codes.
-- WHY: Query 14 found 4,382 total blank-description rows; 2,689
--      were already characterized as an undocumented negative-
--      quantity category (Phase 3). Query 15 isolated the
--      remaining 1,693. This confirms they are a distinct,
--      separate pattern: zero-price, positive-quantity,
--      no-customer entries that read as inventory/stock
--      movements rather than sales transactions.
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_price,
    COUNT(*) FILTER (WHERE quantity > 0) AS positive_qty,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS no_customer,
    COUNT(*) FILTER (WHERE stock_code !~ '^[0-9]+[A-Za-z]*$') AS non_standard_stock_code
FROM uk_retail.raw_transactions
WHERE (description IS NULL OR TRIM(description) = '')
AND NOT (quantity < 0 AND (customer_id IS NULL OR TRIM(customer_id) = ''));