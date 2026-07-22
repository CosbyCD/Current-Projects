-- Query 52_frequency_comparison

-- ============================================================
-- CHAPTER TWO, FIELD 2: Frequency — comparison of both definitions
-- WHAT: Combines the completed-orders-only frequency (query 50)
--       and the all-distinct-orders frequency (query 51) into
--       one result, with the gap between them per customer.
-- WHY: Following this project's standard practice of comparing
--      both sides of a methodology question directly, the same
--      way return rate's order-level and line-item-level
--      versions were compared in Chapter One (query 13). The
--      gap column surfaces which customers' frequency picture
--      changes most depending on whether cancellations count.
--      Not the origin of this practice -- building both sides of
--      a genuine methodological fork is a working habit that
--      predates this project, applied here in SQL for the first
--      time at Queries 11-13 (return rate). What happens at
--      Query 52/53 is narrower: this is the point where that
--      standing habit gets stated explicitly as an instruction
--      to Claude, so it applies as a default going forward
--      rather than being re-specified at every individual fork.
-- ============================================================
SELECT
    a.customer_id,
    a.frequency_completed_only,
    b.frequency_all_orders,
    (b.frequency_all_orders - a.frequency_completed_only) AS cancellation_gap
FROM (
    SELECT customer_id, COUNT(DISTINCT invoice_no) AS frequency_completed_only
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%'
    GROUP BY customer_id
) a
JOIN (
    SELECT customer_id, COUNT(DISTINCT invoice_no) AS frequency_all_orders
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) b ON a.customer_id = b.customer_id
ORDER BY cancellation_gap DESC;

-- RESULT: 5,880 rows returned -- an exact match to Query 50's
-- completed-only row count, NOT Query 51's full 5,941. Confirmed by
-- inspecting the query itself: a plain JOIN (inner join) means any
-- customer_id present in subquery b (all orders) but absent from
-- subquery a (completed orders only) is silently excluded from the
-- result entirely. The 61 customers whose entire order history is
-- cancellations (identified when Query 50 was retrofitted) do not
-- appear here at all -- not as rows with cancellation_gap equal to
-- their full order count, but as missing rows. Top customer 14911
-- confirmed: 398 completed, 510 all orders, gap of 112, matching the
-- log exactly. The gap is not trivial or evenly distributed -- dozens
-- of customers show double-digit gaps beyond the top row.

-- CONFIRMED FINDING: This comparison query, as written, does NOT cover
-- the full 5,941-customer population -- the inner join silently omits
-- the 61 all-cancelled customers, understating the true population
-- this comparison should represent. This is a real gap in this
-- specific query, not a hypothetical risk: it was flagged as a
-- possibility when Query 50 was retrofitted, and this is now confirmed
-- as the actual behavior. Per the investigation log, Query 53 --
-- described as "relabeling and reordering query 52's logic as the
-- official field structure" -- produces a final field with "one row
-- per customer (5,941 rows)," meaning the join logic must have been
-- changed from inner to a form that retains all customers (e.g. LEFT
-- JOIN from the all-orders side, with completed-only defaulting to 0)
-- somewhere between this query and Query 53, even though the log's
-- own description of that step undersells it as mere relabeling. The
-- gap itself (112 for the top customer, and substantial for many
-- others) is confirmed real and behaviorally meaningful, motivating
-- the decision to track frequency_completed and cancellation_count as
-- two permanent, separately kept fields rather than collapsing to one
-- number.