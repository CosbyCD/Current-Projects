-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD (v3): Frequency — completed orders only
-- WHAT: Re-runs completed-orders-only frequency against
--       clean_transactions after the third amendment (query 74).
-- WHY: The 80,995-unit stock_code 23843 transaction (customer
--       16446) carried a real, distinct invoice number and would
--       have been counted as a completed order in prior versions
--       of this field. Confirming it's no longer counted.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_completed_only
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY frequency_completed_only DESC;