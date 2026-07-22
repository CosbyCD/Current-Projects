-- Query 51_frequency_all_distinct_orders

-- ============================================================
-- CHAPTER TWO, FIELD 2: Frequency — all distinct orders
-- WHAT: Counts distinct orders per customer, INCLUDING
--       cancelled orders (invoice_no starting with 'C') as
--       their own distinct order events.
-- WHY: Second of two frequency definitions being built and
--      compared. This version treats frequency as a measure of
--      overall order-placing engagement/activity, regardless of
--      whether the order was ultimately completed or cancelled.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_all_orders
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY frequency_all_orders DESC;

-- RESULT: Top customer is 14911 with 510 total orders (398 completed
-- + 112 cancelled), matching the log exactly -- a gap of 112 from
-- Query 50's completed-only count for the same customer. Result set
-- contains all 5,941 customers (rows fully populated 1 through the max
-- observed), confirming this version of the field correctly includes
-- the 61 all-cancelled customers that Query 50's WHERE clause excluded
-- entirely -- since this query has no cancellation filter, every
-- customer with at least one order of any kind appears here.

-- CONFIRMED FINDING: Frequency (all distinct orders) built
-- successfully, top customer and gap both confirmed against the log.
-- This field, unlike Query 50's, naturally covers the full 5,941-
-- customer population without needing a special join or LEFT JOIN
-- consideration -- it's Query 50 (the narrower, filtered version) that
-- required care to avoid silently dropping customers when the two were
-- eventually compared. Sets up Query 52's direct side-by-side join of
-- both frequency definitions, and the cancellation_gap analysis that
-- follows from it.