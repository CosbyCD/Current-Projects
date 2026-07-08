-- ============================================================
-- FINDING: Cross-check against missing CustomerID group
-- WHAT: Of the 2,689 negative-quantity/blank-description rows,
--       how many have a customer_id vs. how many don't.
-- WHY: Query 06 showed the anomalous row (556012) had no
--      customer_id at all, unlike the genuine cancellation
--      next to it. Testing whether that holds across the full
--      2,689-row pattern — i.e., whether this undocumented
--      category overlaps with the original no-CustomerID
--      finding (243,007 rows, 22.8% of dataset).
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS no_customer,
    COUNT(*) FILTER (WHERE customer_id IS NOT NULL AND TRIM(customer_id) != '') AS has_customer
FROM uk_retail.raw_transactions
WHERE quantity < 0
AND (description IS NULL OR TRIM(description) = '');