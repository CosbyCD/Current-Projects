-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD (v3): Frequency — all distinct orders
-- WHAT: Re-runs all-distinct-orders frequency against
--       clean_transactions after the third amendment (query 74).
-- WHY: Same rebuild rationale as query 78 — confirming the
--       excluded 80,995-unit invoice (customer 16446) is no
--       longer counted in either frequency component.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_all_orders
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY frequency_all_orders DESC;