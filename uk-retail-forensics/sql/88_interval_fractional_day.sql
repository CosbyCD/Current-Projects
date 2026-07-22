-- Query 88_interval_fractional_day

-- ============================================================
-- CHAPTER TWO, FIELD 4: Order-to-Order Interval — fractional day
-- WHAT: Rebuilds the order-to-order interval field using
--       EXTRACT(EPOCH FROM ...) divided by 86,400 seconds,
--       preserving sub-day precision instead of rounding to
--       whole days.
-- WHY: Query 86's spot-check on customer 18139 showed genuine
--      same-day repeat orders (hours apart) being rounded down
--      to a 0.0-day average under the whole-day measurement.
--      Built as the second side of a genuine measurement fork,
--      consistent with this project's standing practice of
--      building both sides rather than settling on one
--      definition in advance.
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

-- RESULT: 4,233 rows -- identical population to the whole-day version
-- (Query 85), confirming both are built from the same underlying
-- order data and differ only in measurement precision. Customer 18139
-- confirmed at 0.17 days, correctly distinguishing their tightly-
-- clustered orders from a true zero-gap, versus the 0.0 the whole-day
-- version showed for this same customer. Their orders_used_in_calc
-- shows 5, consistent with the 6 completed orders directly confirmed
-- at Query 86 (6 orders produce 5 consecutive-order gaps, the same
-- N-1 relationship already established at Query 85). Customer 14911
-- shows 1.98 days average (vs. an unverified whole-day figure), with
-- orders_used_in_calc = 372, matching Query 85's value for this same
-- customer exactly.

-- CONFIRMED FINDING: The fractional-day interval field is confirmed
-- built from identical underlying order data as the whole-day version
-- (same row count, same orders_used_in_calc per customer where
-- checked), differing only in precision. Customer 18139 directly
-- confirms the field solves the problem it was built for: same-day
-- clustered orders now show a small but nonzero average (0.17 days)
-- instead of collapsing to 0.0. Both whole-day and fractional-day
-- versions are kept side by side per this project's standing
-- methodology, rather than choosing one as the final field -- the
-- comparison itself is the deliverable, consistent with the same
-- practice applied to return rate, frequency, and monetary value
-- earlier in this project.