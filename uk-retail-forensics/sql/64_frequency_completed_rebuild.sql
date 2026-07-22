-- Query 64_frequency_completed_rebuild

-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD: Frequency — completed orders only
-- WHAT: Re-runs the completed-orders-only frequency (originally
--       query 50) against the amended clean_transactions.
-- WHY: Query 59 amended clean_transactions to exclude
--       administrative stock codes, which query 57 proved can
--       carry real invoice numbers and customer attribution
--       (e.g., customer 12918's "Manual" entries). Frequency
--       must be rebuilt to confirm those administrative
--       invoice numbers aren't being counted as real orders.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_completed_only
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY frequency_completed_only DESC;

-- RESULT: Top customer 14911 dropped from 398 (Query 50) to 373
-- completed orders, matching the log exactly -- confirming 25 of the
-- original count were administrative entries rather than real orders.
-- 5,852 rows returned. Using the already-confirmed total customer
-- count of 5,875 (Query 62), this means exactly 23 customers now have
-- zero completed orders in the amended table (5,875 - 5,852 = 23) --
-- down from the 61 originally found at Query 50, pre-amendment.

-- CONFIRMED FINDING: Frequency (completed orders only) successfully
-- rebuilt against the amended table, top customer confirmed against
-- the log. The zero-completed-orders population has shrunk from 61 to
-- 23 customers as a direct consequence of this amendment -- consistent
-- with the fact that some of the original 61 were themselves
-- administrative-only customers (among the 66 removed entirely at
-- Query 63) rather than genuine customers whose only real order
-- activity was cancelled. This field, like Query 50 before it, still
-- silently omits these 23 customers as missing rows rather than
-- representing them with a value of 0 -- the same structural property
-- flagged at Query 50, now carried forward unchanged into the rebuild.