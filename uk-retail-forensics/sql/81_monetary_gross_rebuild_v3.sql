-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD (v3): Monetary Value — gross
-- WHAT: Re-runs monetary_gross against clean_transactions after
--       the third amendment (query 74), which excluded the
--       80,995-unit stock_code 23843 outlier.
-- WHY: Customer 16446's monetary_gross was almost entirely
--      driven by the now-excluded 80,995-unit transaction
--      ($168,469.60 of their $168,472.50 total). This rebuild
--      should show their gross value drop to just the two
--      small legitimate items from invoice 553573 (roughly
--      $2.90 combined).
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY monetary_gross DESC;