-- ============================================================
-- FOLLOW-UP: Nearby customer_id check — expanded range
-- WHAT: Re-runs the query 30 neighbor comparison with a much
--       wider numeric range around 13256 (13226–13866) instead
--       of the original narrow window (13246–13266).
-- WHY: Query 30 only checked a tight sequential neighborhood,
--      which would catch a simple left/right digit slip but
--      would miss other realistic data-entry errors — a
--      mistyped digit doesn't have to land immediately adjacent
--      in numeric sequence; it can be off by a wider margin
--      depending on how the error actually happened (a keypad
--      slip, a fingernail catching an adjacent key vertically
--      as well as horizontally). Widening the range gives a
--      fuller picture of whether 13256's single-order anomaly
--      is unique in a broader neighborhood, not just its
--      immediate numeric neighbors.
-- ============================================================
SELECT customer_id, COUNT(*) AS order_count
FROM uk_retail.raw_transactions
WHERE TRIM(customer_id) != ''
AND customer_id::NUMERIC BETWEEN 13226 AND 13866
GROUP BY customer_id
ORDER BY customer_id;