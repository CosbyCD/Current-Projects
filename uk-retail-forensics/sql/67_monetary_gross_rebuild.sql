-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD: Monetary Value — gross
-- WHAT: Re-runs monetary_gross (originally query 54) against
--       the amended clean_transactions.
-- WHY: Query 57 traced the exact-doubling anomaly (customer
--       12918 and others) to administrative "Manual" entries.
--       This rebuild should resolve that anomaly entirely,
--       since those rows are now excluded at the source.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY monetary_gross DESC;