-- ============================================================
-- CHAPTER TWO, FIELD 4: Order-to-Order Interval
-- WHAT: Calculates the average number of days between a
--       customer's consecutive completed orders. Only
--       meaningful for customers with 2+ distinct completed
--       orders — a single-order customer has no interval to
--       measure and will not appear in this result.
-- WHY: Fourth of the six derived customer behavior fields.
--      Uses completed orders only (excluding cancellations),
--      consistent with the completed-orders-first approach
--      established for frequency — a cancelled order doesn't
--      represent a genuine return visit.
-- ============================================================
WITH order_dates AS (
    SELECT DISTINCT customer_id, invoice_no, MIN(invoice_date) AS order_date
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    AND invoice_no NOT LIKE 'C%'
    GROUP BY customer_id, invoice_no
),
gaps AS (
    SELECT
        customer_id,
        order_date,
        order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS days_since_prior_order
    FROM order_dates
)
SELECT
    customer_id,
    COUNT(*) AS orders_used_in_calc,
    ROUND(AVG(EXTRACT(DAY FROM days_since_prior_order))::NUMERIC, 1) AS avg_days_between_orders
FROM gaps
WHERE days_since_prior_order IS NOT NULL
GROUP BY customer_id
ORDER BY avg_days_between_orders;