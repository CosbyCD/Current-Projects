-- Query 85_interval_completed_orders

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

-- RESULT: 4,233 rows -- only customers with 2+ completed orders
-- appear, consistent with the field's stated design (single-order
-- customers are excluded by construction, not by error). Values range
-- from 0.0 days (customers who placed multiple completed orders on
-- the same calendar day) up to 714.0 days (customers whose two orders
-- bookend nearly the entire dataset window). Cross-check confirmed
-- directly: customer 14911 shows orders_used_in_calc = 372, exactly
-- their frequency_completed value (373, confirmed at Query 78) minus
-- one -- matching the log's cross-check claim precisely and
-- confirming this field draws from the same underlying completed-
-- order data as Field 2.

-- CONFIRMED FINDING: The interval field is built correctly and
-- verified consistent with Field 2's frequency data at the individual
-- customer level. The orders_used_in_calc = frequency_completed - 1
-- relationship holds exactly, as expected (N orders produce N-1 gaps
-- between consecutive orders). 5,875 - 4,233 = 1,642 customers with
-- fewer than 2 completed orders (0 or 1) are correctly and
-- intentionally absent from this result, not silently dropped in
-- error -- worth carrying forward as a known population gap the same
-- way the zero-completed-order customers were tracked through Field
-- 2's construction, since this field will need the same LEFT JOIN /
-- NULL-handling care when combined into the final customer_behavior_
-- fields table (Query 94).