-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD (v3): Monetary Value — net
-- WHAT: Re-runs monetary_net against clean_transactions after
--       the third amendment (query 74), which excluded the
--       80,995-unit stock_code 23843 outlier (both the purchase
--       and its cancellation).
-- WHY: Since the purchase and cancellation exactly offset each
--      other, customer 16446's monetary_net should barely
--      change from the second-rebuild figure ($578,408.64 →
--      wait, that's not 16446's number, that's 18102's; 16446's
--      net was already near their gross minus that pair's net
--      contribution of ~$0). This confirms whether removing a
--      self-cancelling pair changes monetary_net at all, versus
--      monetary_gross where it mattered significantly.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_net
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary_net DESC;