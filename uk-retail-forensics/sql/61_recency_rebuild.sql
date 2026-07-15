-- ============================================================
-- CHAPTER TWO, FIELD 1: Recency — rebuild against amended table
-- WHAT: Re-runs the recency field (originally query 45) against
--       the amended clean_transactions (post query 59), which
--       now excludes administrative stock codes.
-- WHY: Query 59 amended clean_transactions after discovering
--      administrative codes (POST, DOT, M, etc.) had leaked
--      through the original build. Recency must be rebuilt to
--      confirm it wasn't affected by rows tied to those codes.
-- ============================================================
SELECT
    customer_id,
    MAX(invoice_date) AS last_order_date,
    EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM uk_retail.clean_transactions) - MAX(invoice_date))::INT AS recency_days
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY recency_days;