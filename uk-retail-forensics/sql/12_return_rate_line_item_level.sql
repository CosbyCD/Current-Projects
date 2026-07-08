-- ============================================================
-- INVESTIGATION: Return rate — line-item-level calculation
-- WHAT: Calculates return rate as proportion of a customer's
--       LINE ITEMS that were cancellations, out of their total
--       line items across all orders.
-- WHY: Second of two approaches being tested. Measures at the
--      individual product-line level rather than the whole-
--      order level, so a single cancelled item in a 10-line
--      order shows as 1/10 cancelled rather than a fully
--      cancelled order — comparing against query 11 to decide
--      which level better reflects actual customer behavior.
-- ============================================================
SELECT
    customer_id,
    COUNT(*) AS total_line_items,
    SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS cancelled_line_items,
    ROUND(SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 4) AS line_item_return_rate
FROM uk_retail.raw_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id;