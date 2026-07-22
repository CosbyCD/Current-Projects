-- Query 50_frequency_completed_orders_only

-- ============================================================
-- CHAPTER TWO, FIELD 2: Frequency — completed orders only
-- WHAT: Counts distinct orders per customer, EXCLUDING
--       cancelled orders (invoice_no starting with 'C').
-- WHY: First of two frequency definitions being built and
--      compared, following this project's standard practice
--      (established with return rate in Chapter One) of testing
--      both sides of a genuine methodological question rather
--      than picking one blind. This version treats frequency as
--      a measure of actual completed purchasing behavior.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_completed_only
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY frequency_completed_only DESC;

-- RESULT: Top customer is 14911 with 398 completed orders, matching
-- the value cited in the investigation log. Result set contains 5,880
-- rows -- 61 fewer than the 5,941 total distinct customers established
-- in Query 47. This gap follows directly from the WHERE clause: any
-- customer whose entire order history consists exclusively of
-- cancelled ('C'-prefix) invoices has zero completed orders and simply
-- does not appear in this GROUP BY result, rather than appearing with
-- a value of 0.

-- CONFIRMED FINDING: Frequency (completed orders only) built
-- successfully, top customer 14911 at 398 orders confirmed against the
-- log. This field alone would silently drop the 61 all-cancelled
-- customers if used as-is, which matters directly for Query 52's
-- planned side-by-side comparison against Query 51 (all orders
-- including cancellations) -- a naive inner join between the two
-- results would lose those 61 customers from the comparison entirely.
-- Flagged here as an open question for whoever builds that comparison
-- next, not yet resolved.