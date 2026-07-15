-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD (v3): Frequency comparison
-- WHAT: Re-runs the frequency comparison against
--       clean_transactions after the third amendment (query 74),
--       joining the rebuilt completed-only and all-orders counts
--       with the cancellation gap between them.
-- WHY: Confirms customer 16446's cancellation_gap is now
--       correctly 0, and that no other customer's gap was
--       affected by this amendment (since the excluded rows
--       belonged only to 16446).
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