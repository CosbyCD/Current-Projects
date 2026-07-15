-- ============================================================
-- CHAPTER TWO, FIELD 6: Return Rate — line-item-level (rebuild)
-- WHAT: Recalculates line-item-level return rate per customer
--       against clean_transactions, following the methodology
--       established in Chapter One (query 12).
-- WHY: Second of the two return rate measures being rebuilt
--      against the clean table, completing the both-sides
--      comparison already established in Chapter One.
-- ============================================================
SELECT
    customer_id,
    COUNT(*) FILTER (WHERE invoice_no LIKE 'C%') AS cancelled_line_items,
    COUNT(*) AS total_line_items,
    ROUND(100.0 * COUNT(*) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(*), 1) AS line_item_return_rate_pct
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY line_item_return_rate_pct DESC;