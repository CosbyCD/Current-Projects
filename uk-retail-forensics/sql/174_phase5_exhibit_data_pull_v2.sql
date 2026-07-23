-- Query 174_phase5_exhibit_data_pull_v2

-- WHAT: Rebuilds Query 172's combined exhibit dataset using the
--       retightened Overdue Restock definition (Query 173: 8x
--       multiple, £1,000 value floor) in place of the original,
--       too-loose 3x threshold. Dead Stock Candidate and Seasonal
--       Dormant logic unchanged from Query 172, already verified
--       correct.
-- WHY: Query 172's pull is superseded -- its Overdue Restock category
--      (1,532 rows, 88% of the exhibit) was built on the threshold
--      Query 171 found too loose. This is the corrected version, ready
--      for actual exhibit use.

WITH seasonal_skus AS (
    WITH dead_stock AS (
        SELECT stock_code FROM uk_retail.stock_behavior_fields
        WHERE recency_days >= 377 AND frequency_completed IS NOT NULL AND frequency_completed <= 3
    ),
    order_months AS (
        SELECT ft.stock_code, EXTRACT(MONTH FROM ft.invoice_date) AS order_month,
            COUNT(DISTINCT ft.invoice_no) AS orders_this_month
        FROM uk_retail.full_transactions ft
        JOIN dead_stock ds ON ds.stock_code = ft.stock_code
        WHERE ft.invoice_no NOT LIKE 'C%'
        GROUP BY ft.stock_code, EXTRACT(MONTH FROM ft.invoice_date)
    ),
    totals AS (SELECT stock_code, SUM(orders_this_month) AS total_orders FROM order_months GROUP BY stock_code)
    SELECT DISTINCT om.stock_code
    FROM order_months om JOIN totals t ON t.stock_code = om.stock_code
    WHERE om.orders_this_month = t.total_orders AND om.order_month IN (11, 12)
)
SELECT
    stock_code,
    recency_days,
    monetary_net,
    frequency_completed,
    CASE
        WHEN frequency_completed >= 5
             AND avg_interval_fractional_day IS NOT NULL
             AND recency_days >= 8 * avg_interval_fractional_day
             AND monetary_net >= 1000
        THEN 'Overdue Restock'
        WHEN recency_days >= 377 AND frequency_completed <= 3 AND stock_code IN (SELECT stock_code FROM seasonal_skus)
        THEN 'Seasonal Dormant'
        WHEN recency_days >= 377 AND frequency_completed <= 3
        THEN 'Dead Stock Candidate'
    END AS category
FROM uk_retail.stock_behavior_fields
WHERE (frequency_completed >= 5
       AND avg_interval_fractional_day IS NOT NULL
       AND recency_days >= 8 * avg_interval_fractional_day
       AND monetary_net >= 1000)
   OR (recency_days >= 377 AND frequency_completed <= 3)
ORDER BY category, recency_days DESC;