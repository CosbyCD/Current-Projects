-- ============================================================
-- CHAPTER TWO, FIELD 1 REBUILD (v3): Recency
-- WHAT: Re-runs the recency field against clean_transactions
--       after the third amendment (query 74), which excluded
--       the 80,995-unit stock_code 23843 outlier.
-- WHY: Query 74 invalidated the row-level correctness of every
--      field built against the prior table version. Recency is
--      unlikely to be affected (it only cares about a
--      customer's single most recent transaction date), but
--      this must be confirmed, not assumed.
-- ============================================================
SELECT
    customer_id,
    MAX(invoice_date) AS last_order_date,
    EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM uk_retail.clean_transactions) - MAX(invoice_date))::INT AS recency_days
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY recency_days;