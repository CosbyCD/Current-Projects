-- Query 61_recency_rebuild

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

-- RESULT: Customer 13468 confirmed unchanged: last_order_date
-- 2011-12-08 10:39:00, recency_days = 1, matching the log exactly and
-- identical to the pre-amendment value from Query 45. Row count for
-- this result is 5,875 -- fewer than the pre-amendment 5,941 -- a
-- real, visible change in this query's own output, not yet explained
-- within this query.

-- CONFIRMED FINDING: PASSED at the individual-customer level. Customer
-- 13468's recency value is confirmed unaffected by the administrative-
-- code amendment, a good early sign the field's underlying logic
-- wasn't structurally broken by the change. The overall row count drop
-- (5,941 to 5,875) is real and visible in this result, but its cause
-- is not yet investigated at this point in the sequence -- worth
-- confirming directly rather than assuming, next.