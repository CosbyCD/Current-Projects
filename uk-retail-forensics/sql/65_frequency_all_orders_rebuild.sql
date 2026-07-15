-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD: Frequency — all distinct orders
-- WHAT: Re-runs the all-distinct-orders frequency (originally
--       query 51) against the amended clean_transactions.
-- WHY: Same rebuild rationale as query 64 — confirming
--       administrative-code invoice numbers aren't inflating
--       the all-orders count either.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_all_orders
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY frequency_all_orders DESC;