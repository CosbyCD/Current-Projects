-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD: Monetary Value — net
-- WHAT: Re-runs monetary_net (originally query 55) against the
--       amended clean_transactions.
-- WHY: Query 57 traced the exact-doubling anomaly (customers
--       16446, 12918, 14802, 15802, 13290) to administrative
--       "Manual" and similar entries. This rebuild should
--       resolve the anomaly for all five customers, not just
--       12918, since the underlying rows are now excluded at
--       the source across the board.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_net
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary_net DESC;