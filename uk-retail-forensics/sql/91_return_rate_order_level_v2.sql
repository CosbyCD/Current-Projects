-- ============================================================
-- CHAPTER TWO, FIELD 6: Return Rate — order-level (rebuild)
-- WHAT: Recalculates order-level return rate per customer —
--       cancelled orders divided by total orders — against
--       clean_transactions, following the same methodology
--       established in Chapter One (query 11) but built against
--       raw_transactions at the time.
-- WHY: Sixth and final of the six derived customer behavior
--      fields. The methodology decision (order-level vs.
--      line-item-level, both tracked) was already made and
--      compared in Chapter One; this rebuild applies it to the
--      clean, fully reconciled table rather than repeating the
--      investigation.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%') AS cancelled_orders,
    COUNT(DISTINCT invoice_no) AS total_orders,
    ROUND(100.0 * COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(DISTINCT invoice_no), 1) AS order_return_rate_pct
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY order_return_rate_pct DESC;
