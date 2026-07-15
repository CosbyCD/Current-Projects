-- ============================================================
-- CHAPTER TWO, FIELD 2: Frequency — comparison of both definitions
-- WHAT: Combines the completed-orders-only frequency (query 50)
--       and the all-distinct-orders frequency (query 51) into
--       one result, with the gap between them per customer.
-- WHY: Following this project's standard practice of comparing
--      both sides of a methodology question directly, the same
--      way return rate's order-level and line-item-level
--      versions were compared in Chapter One (query 13). The
--      gap column surfaces which customers' frequency picture
--      changes most depending on whether cancellations count.
-- ============================================================
SELECT
    a.customer_id,
    a.frequency_completed_only,
    b.frequency_all_orders,
    (b.frequency_all_orders - a.frequency_completed_only) AS cancellation_gap
FROM (
    SELECT customer_id, COUNT(DISTINCT invoice_no) AS frequency_completed_only
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%'
    GROUP BY customer_id
) a
JOIN (
    SELECT customer_id, COUNT(DISTINCT invoice_no) AS frequency_all_orders
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) b ON a.customer_id = b.customer_id
ORDER BY cancellation_gap DESC;