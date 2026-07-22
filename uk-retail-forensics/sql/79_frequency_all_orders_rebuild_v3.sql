-- Query 79_frequency_all_orders_rebuild_v3

-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD (v3): Frequency — all distinct orders
-- WHAT: Re-runs all-distinct-orders frequency against
--       clean_transactions after the third amendment (query 74).
-- WHY: Same rebuild rationale as query 78 — confirming the
--       excluded 80,995-unit invoice (customer 16446) is no
--       longer counted in either frequency component.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_all_orders
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY frequency_all_orders DESC;

-- RESULT: Top customer 14911 unchanged at 466. 5,875 rows total,
-- matching the full current customer population (Query 76/77).
-- Customer 16446 confirmed at exactly 1 -- identical to their
-- frequency_completed value from Query 78.

-- CONFIRMED FINDING: PASSED. Customer 16446's frequency_all_orders
-- (1) now exactly matches their frequency_completed (1) from Query
-- 78, meaning their cancellation_gap resolves to precisely 0 -- fully
-- resolved from whatever inflated figure previously included the
-- erroneous 80,995-unit invoice and its cancellation. Both components
-- confirmed directly at the individual-customer level, not inferred.
-- See Query 80 for the full rebuilt comparison, which per the log
-- confirms no other customer's numbers were affected by this
-- amendment beyond 16446.