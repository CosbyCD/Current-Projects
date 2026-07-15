-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD: Frequency — completed orders only
-- WHAT: Re-runs the completed-orders-only frequency (originally
--       query 50) against the amended clean_transactions.
-- WHY: Query 59 amended clean_transactions to exclude
--       administrative stock codes, which query 57 proved can
--       carry real invoice numbers and customer attribution
--       (e.g., customer 12918's "Manual" entries). Frequency
--       must be rebuilt to confirm those administrative
--       invoice numbers aren't being counted as real orders.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_completed_only
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY frequency_completed_only DESC;