-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD: Frequency comparison
-- WHAT: Re-runs the frequency comparison (originally query 52)
--       against the amended clean_transactions, joining the
--       rebuilt completed-only and all-orders counts with the
--       cancellation gap between them.
-- WHY: Confirms the final cancellation_count field reflects
--      genuine customer cancellation behavior only, now that
--      administrative stock codes have been excluded from the
--      underlying data.
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