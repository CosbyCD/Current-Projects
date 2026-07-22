-- Query 66_frequency_comparison_rebuild

-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD: Frequency comparison
-- WHAT: Re-runs the frequency comparison (originally query 52)
--       against the amended clean_transactions, joining the
--       rebuilt completed-only and all-orders counts with the
--       cancellation gap between them.
-- WHY: Confirms the final cancellation_count field reflects
--      genuine customer cancellation behavior only, now that
--      administrative stock codes have been excluded from the
--      underlying data.
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

-- RESULT: Top row confirmed exactly against the log: customer 14911
-- at 373 completed / 466 all orders / 93 cancellation gap (down from
-- the original 112 -- a 19-order reduction, meaning roughly a sixth of
-- this customer's originally-measured "cancellations" were
-- administrative invoice activity, not genuine cancelled purchases).
-- 5,852 rows returned -- the same row count as Query 64's completed-
-- only population, confirming this rebuild carries forward the
-- identical inner-join structure (and the same resulting omission of
-- the 23 zero-completed-order customers) already flagged at Query 52
-- and Query 64.

-- CONFIRMED FINDING: The rebuilt comparison confirms the
-- administrative-code contamination directly at the individual-
-- customer level, not just in aggregate -- customer 14911's
-- cancellation gap shrinpeds from 112 to 93 specifically because 19 of
-- the original 112 "cancelled" invoice numbers were administrative
-- entries, not genuine customer-initiated cancellations. This is
-- exactly the contamination the Query 59 amendment was built to catch
-- and remove, now confirmed at the field level. The same 23-customer
-- gap already flagged at Query 64 (zero-completed-order customers
-- silently absent, not shown as zero) persists unchanged into this
-- rebuilt comparison -- worth tracking forward the same way it was
-- tracked from Query 52 into the original Query 53's final field.