-- ============================================================
-- CHAPTER TWO, FIELD 1: Recency
-- WHAT: Calculates recency — whole days since each customer's
--       most recent order — using clean_transactions as the
--       source, with EXTRACT(DAY FROM ...) to return a clean
--       integer rather than a full interval.
-- WHY: First of the six derived customer behavior fields.
--      Built against clean_transactions so duplicate rows,
--      excluded internal-activity rows, and the confirmed
--      outlier don't distort the result. Reference point is
--      the dataset's own most recent transaction date (Dec 9,
--      2011), not today's real-world date, since this is a
--      fixed historical dataset and recency needs a stable
--      reference point within that window to be meaningful.
-- ============================================================
SELECT
    customer_id,
    MAX(invoice_date) AS last_order_date,
    EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM uk_retail.clean_transactions) - MAX(invoice_date))::INT AS recency_days
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY recency_days;