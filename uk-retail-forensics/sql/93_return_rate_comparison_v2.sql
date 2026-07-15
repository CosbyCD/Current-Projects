-- ============================================================
-- CHAPTER TWO, FIELD 6: Return Rate — comparison (rebuild)
-- WHAT: Joins the rebuilt order-level (query 91) and line-item-
--       level (query 92) return rates into one result, with the
--       percentage-point gap between them per customer.
-- WHY: Same both-sides comparison practice applied throughout
--      this chapter. The gap shows which customers' return
--      rate picture changes most depending on which
--      granularity is used to measure it.
-- ============================================================
SELECT
    a.customer_id,
    a.order_return_rate_pct,
    b.line_item_return_rate_pct,
    ROUND(a.order_return_rate_pct - b.line_item_return_rate_pct, 1) AS rate_gap_pct
FROM (
    SELECT customer_id,
           ROUND(100.0 * COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(DISTINCT invoice_no), 1) AS order_return_rate_pct
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) a
JOIN (
    SELECT customer_id,
           ROUND(100.0 * COUNT(*) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(*), 1) AS line_item_return_rate_pct
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) b ON a.customer_id = b.customer_id
ORDER BY ABS(a.order_return_rate_pct - b.line_item_return_rate_pct) DESC;