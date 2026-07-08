-- ============================================================
-- DERIVED FIELD: Return rate — order-level vs. line-item-level
-- WHAT: Calculates customer return rate two ways — proportion
--       of ORDERS cancelled, and proportion of LINE ITEMS
--       cancelled — then shows the gap between them per customer.
-- WHY: A single cancelled line item within a large multi-line
--      order looks very different depending on which level you
--      measure at. Building both and comparing, rather than
--      picking one blind, so the difference itself becomes
--      part of the analysis. Sorted by largest gap to surface
--      customers worth a manual row-level check next.
-- ============================================================
WITH order_level AS (
    SELECT
        customer_id,
        invoice_no,
        MAX(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS is_cancelled
    FROM uk_retail.raw_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice_no
),
order_rate AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(is_cancelled) AS cancelled_orders,
        ROUND(SUM(is_cancelled)::NUMERIC / COUNT(*), 4) AS order_level_rate
    FROM order_level
    GROUP BY customer_id
),
line_rate AS (
    SELECT
        customer_id,
        COUNT(*) AS total_line_items,
        SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS cancelled_line_items,
        ROUND(SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 4) AS line_item_rate
    FROM uk_retail.raw_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    o.customer_id,
    o.total_orders,
    o.cancelled_orders,
    o.order_level_rate,
    l.total_line_items,
    l.cancelled_line_items,
    l.line_item_rate,
    ROUND(o.order_level_rate - l.line_item_rate, 4) AS rate_gap
FROM order_rate o
JOIN line_rate l ON o.customer_id = l.customer_id
ORDER BY ABS(o.order_level_rate - l.line_item_rate) DESC;