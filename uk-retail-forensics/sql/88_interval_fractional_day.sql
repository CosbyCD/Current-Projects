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
        EXTRACT(EPOCH FROM (order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date))) / 86400.0 AS days_since_prior_order
    FROM order_dates
)
SELECT
    customer_id,
    COUNT(*) AS orders_used_in_calc,
    ROUND(AVG(days_since_prior_order)::NUMERIC, 2) AS avg_days_between_orders_fractional
FROM gaps
WHERE days_since_prior_order IS NOT NULL
GROUP BY customer_id
ORDER BY avg_days_between_orders_fractional;