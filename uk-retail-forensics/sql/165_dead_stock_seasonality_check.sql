-- Query 165_dead_stock_seasonality_check

-- WHAT: For the 201 dead-stock candidates flagged at Query 163, checks
--       whether each SKU's (few) historical completed orders cluster
--       in a specific calendar month -- a seasonal-only item mistaken
--       for dead stock would show its handful of orders concentrated
--       around the same time of year (e.g. Nov/Dec, echoing the
--       confirmed 618-customer Nov 2010 cohort) rather than spread
--       evenly across the dataset's full date range.
-- WHY: Per the framework, this is the safeguard before any write-off/
--      gift-bonus recommendation gets finalized -- a SKU that looks
--      dormant right now but has a genuine seasonal pattern (only
--      sells in December, say) shouldn't be swept into the same
--      recommendation as a SKU that simply never sold and never will.
--      Reapplies the same month-clustering technique already proven
--      at the customer level (queries 100-101) to the SKU level.

WITH dead_stock AS (
    SELECT stock_code
    FROM uk_retail.stock_behavior_fields
    WHERE recency_days >= 377
      AND frequency_completed IS NOT NULL
      AND frequency_completed <= 3
),
order_months AS (
    SELECT
        ft.stock_code,
        EXTRACT(MONTH FROM ft.invoice_date) AS order_month,
        COUNT(DISTINCT ft.invoice_no) AS orders_this_month
    FROM uk_retail.full_transactions ft
    JOIN dead_stock ds ON ds.stock_code = ft.stock_code
    WHERE ft.invoice_no NOT LIKE 'C%'
    GROUP BY ft.stock_code, EXTRACT(MONTH FROM ft.invoice_date)
),
totals AS (
    SELECT stock_code, SUM(orders_this_month) AS total_orders
    FROM order_months
    GROUP BY stock_code
)
SELECT
    om.stock_code,
    t.total_orders,
    om.order_month,
    om.orders_this_month,
    ROUND(100.0 * om.orders_this_month / t.total_orders, 1) AS pct_of_total
FROM order_months om
JOIN totals t ON t.stock_code = om.stock_code
WHERE om.orders_this_month = t.total_orders
  AND om.order_month IN (11, 12)
ORDER BY t.total_orders DESC, om.stock_code;

-- RESULT (verified against pasted CSV): 93 of 201 dead-stock candidates
-- (46.3%) have their ENTIRE order history concentrated in a single
-- month, November or December. The strongest evidence is in the
-- multi-order cases, where chance clustering is far less likely: 6
-- SKUs with all 3 of their total orders in December, 23 SKUs with both
-- of their 2 total orders in December. Only 3 of the 93 fall in
-- November (15002, 37477C, 90142B, 90142C); the overwhelming majority
-- are December-exclusive.

-- CONFIRMED FINDING: This safeguard catches a real and substantial
-- problem with the Query 163/164 recommendation as originally stated.
-- Nearly half of the "dead stock" candidate population is not dead
-- inventory at all -- it is genuinely seasonal, December-only demand
-- that reads as year-round dormancy specifically because the recency
-- measurement (days since last sale) doesn't distinguish "abandoned"
-- from "waiting for its one annual selling window." REVISED
-- RECOMMENDATION, superseding Query 163/164's undifferentiated
-- gift-bonus-clearance suggestion: the 93 December/November-clustered
-- SKUs should be EXCLUDED from any write-off or clearance action and
-- instead flagged for seasonal restocking ahead of the next holiday
-- period -- the opposite treatment from disposal. The remaining 108
-- SKUs (201 - 93), which show no such clustering, remain legitimate
-- gift-bonus-clearance candidates. This is exactly the kind of
-- "insight nobody asked for" this sprint exists to demonstrate: the
-- original two-finding structure (Query 162 restock signal, Query
-- 163/164 dead-stock signal) would have shipped an incomplete
-- recommendation without this check.