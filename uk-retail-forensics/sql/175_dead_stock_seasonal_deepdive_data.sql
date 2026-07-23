-- Query 175_dead_stock_seasonal_deepdive_data

-- WHAT: Pulls the 201 Dead Stock Candidate + Seasonal Dormant SKUs
--       (Query 163/164/165) with a new derived field -- avg_order_month,
--       the order-count-weighted average calendar month (1-12) across
--       each SKU's completed orders -- as the third exhibit axis, in
--       place of frequency_completed (which only takes values 1-3 for
--       this population and produced the flat, uninformative stripes
--       seen in the combined exhibit).
-- WHY: The combined exhibit (Query 174) showed these two categories
--      separated by color alone, not position -- frequency and recency/
--      monetary don't spatially distinguish them because the actual
--      distinguishing mechanism (Query 165's finding) is WHEN a SKU's
--      handful of orders happened, not how many or how recent. Making
--      that the plotted axis directly, rather than only the category
--      label, should show Seasonal Dormant clustering tightly near
--      month 11-12 while Dead Stock Candidate scatters more broadly --
--      the spatial proof of Query 165's theory, not just a color-coded
--      assertion of it.

WITH target_skus AS (
    SELECT stock_code, recency_days, monetary_net, frequency_completed
    FROM uk_retail.stock_behavior_fields
    WHERE recency_days >= 377
      AND frequency_completed IS NOT NULL
      AND frequency_completed <= 3
),
order_month_weighted AS (
    SELECT
        ft.stock_code,
        AVG(EXTRACT(MONTH FROM ft.invoice_date)) AS avg_order_month
    FROM uk_retail.full_transactions ft
    JOIN target_skus ts ON ts.stock_code = ft.stock_code
    WHERE ft.invoice_no NOT LIKE 'C%'
    GROUP BY ft.stock_code
),
seasonal_skus AS (
    SELECT ts.stock_code
    FROM target_skus ts
    JOIN order_month_weighted omw ON omw.stock_code = ts.stock_code
    JOIN uk_retail.full_transactions ft ON ft.stock_code = ts.stock_code AND ft.invoice_no NOT LIKE 'C%'
    GROUP BY ts.stock_code
    HAVING COUNT(DISTINCT EXTRACT(MONTH FROM ft.invoice_date)) = 1
       AND MIN(EXTRACT(MONTH FROM ft.invoice_date)) IN (11, 12)
)
SELECT
    ts.stock_code,
    ts.recency_days,
    ts.monetary_net,
    ROUND(omw.avg_order_month::NUMERIC, 2) AS avg_order_month,
    CASE WHEN ss.stock_code IS NOT NULL THEN 'Seasonal Dormant' ELSE 'Dead Stock Candidate' END AS category
FROM target_skus ts
JOIN order_month_weighted omw ON omw.stock_code = ts.stock_code
LEFT JOIN seasonal_skus ss ON ss.stock_code = ts.stock_code
ORDER BY category, avg_order_month;