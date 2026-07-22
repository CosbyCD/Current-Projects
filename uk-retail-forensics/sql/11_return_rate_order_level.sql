-- Query 11_return_rate_order_level

-- ============================================================
-- INVESTIGATION: Return rate — order-level calculation
-- WHAT: Calculates return rate as proportion of a customer's
--       ORDERS that were cancellations (invoice_no starting
--       with 'C'), out of their total distinct orders.
-- WHY: First of two approaches being tested to define "return
--      rate" as a derived field. A single cancelled line item
--      within a large multi-line order counts as one fully
--      cancelled order under this method — testing whether
--      that's the right level to measure at, or whether
--      line-item-level tells a truer story.
-- ============================================================
WITH order_level AS (
    SELECT
        customer_id,
        invoice_no,
        MAX(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS is_cancelled
    FROM uk_retail.raw_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice_no
)
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(is_cancelled) AS cancelled_orders,
    ROUND(SUM(is_cancelled)::NUMERIC / COUNT(*), 4) AS order_level_return_rate
FROM order_level
GROUP BY customer_id;

-- RESULT: One row per customer_id, return rate ranging from 0.0000 (no
-- cancelled orders) up to 1.0000 (every order cancelled, typically seen
-- on customers with only 1 total order). Return rates in the pasted
-- sample span the full range widely — e.g. 12346.0 at 0.2941 (17 orders,
-- 5 cancelled), 12748.0 at 0.0767 despite the highest order volume in
-- the sample (365 orders, 28 cancelled), and 13342.0 at 1.0000 (1 order,
-- fully cancelled). ANOMALY NOTED: the result set's first row has a
-- blank customer_id (8,752 total_orders, 391 cancelled, rate 0.0447)
-- despite the query's WHERE customer_id IS NOT NULL filter — this
-- indicates customer_id contains empty-string values that pass a NULL
-- check but are not genuinely populated, aggregating a large number of
-- otherwise-excluded rows into one artificial "customer." This needs
-- to be caught and handled (e.g. TRIM + empty-string check, not just
-- IS NOT NULL) — flagged here as a new, previously undocumented data
-- quality issue distinct from the topic this query was built to answer.

-- CONFIRMED FINDING: Order-level return rate produces a valid per-
-- customer metric, but surfaced an unrelated, previously undocumented
-- data-quality issue: customer_id contains blank/empty-string values
-- that satisfy "IS NOT NULL" while not representing real customer
-- identity, causing 8,752 orders to be silently pooled together under
-- a blank identifier rather than excluded. This must be corrected (using
-- TRIM(customer_id) != '' alongside the NULL check) in this query and
-- any other query using "customer_id IS NOT NULL" as its sole filter,
-- including — critically — this project's earlier customer-level work,
-- which needs to be checked for the same exposure. Pending that fix,
-- this query's per-customer return rate values are usable, but the
-- dataset's true customer count and any aggregate return-rate statistics
-- drawn from this result should not yet be trusted until the blank-
-- customer_id row is excluded and the query re-run.