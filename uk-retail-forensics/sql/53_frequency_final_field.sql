-- ============================================================
-- CHAPTER TWO, FIELD 2: Frequency — final field, both tracked
-- WHAT: Combines completed-order frequency and cancellation
--       count into the final frequency field structure, both
--       tracked side by side rather than collapsed into one
--       number.
-- WHY: Query 52 confirmed the gap between completed-only and
--       all-distinct-order counts is real and substantial for
--       some customers (up to 112 orders for the top case) —
--       not noise to average away. Following this project's
--       established practice (see excluded_rows, Phase 6):
--       nothing gets discarded once investigated, it gets
--       tracked with a clear label. frequency_completed
--       reflects genuine purchase behavior; cancellation_count
--       is a distinct behavioral signal in its own right — a
--       customer who cancels often is behaviorally different
--       from one who rarely does, even at the same completed-
--       order volume.
-- ============================================================
SELECT
    customer_id,
    frequency_completed_only AS frequency_completed,
    cancellation_gap AS cancellation_count
FROM (
    SELECT
        a.customer_id,
        a.frequency_completed_only,
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
) sub
ORDER BY customer_id;