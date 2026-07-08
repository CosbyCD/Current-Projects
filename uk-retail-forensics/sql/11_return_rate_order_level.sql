-- ============================================================
-- INVESTIGATION: Return rate — order-level calculation
-- WHAT: Calculates return rate as proportion of a customer's
--       ORDERS that were cancellations (invoice_no starting
--       with 'C'), out of their total distinct orders.
-- WHY: First of two approaches being tested to define "return
--      rate" as a derived field. A single cancelled line item
--      within a large multi-line order counts as one fully
--      cancelled order under this method — testing whether
--      that's the right level to measure at, or whether
--      line-item-level tells a truer story.
-- ============================================================
WITH order_level AS (
    SELECT
        customer_id,
        invoice_no,
        MAX(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS is_cancelled
    FROM uk_retail.raw_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice_no
)
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(is_cancelled) AS cancelled_orders,
    ROUND(SUM(is_cancelled)::NUMERIC / COUNT(*), 4) AS order_level_return_rate
FROM order_level
GROUP BY customer_id;