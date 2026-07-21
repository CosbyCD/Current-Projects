-- Query 132_never_converted_attempt_count_pull

-- WHAT: Pulls a raw order-attempt count (distinct invoice count, completed and
-- cancelled combined) per customer, alongside recency_days and first_transaction_date,
-- for all 5,875 customers, flagged Never Converted vs. Converted. Built specifically
-- to replace frequency_completed as the third exhibit axis for the Never Converted
-- group, since frequency_completed is NULL for that entire population by definition
-- (zero completed orders) and cannot show any variation within the group.

-- WHY: Query 131 confirmed a real time-clustering pattern in the never-converted
-- group (65% concentrated in the dataset's first three weeks) but found both
-- candidate secondary axes (frequency_completed, active_span_days) degenerate —
-- NULL or 0 for nearly the whole group. A raw attempt count (every invoice, whether
-- it completed or was cancelled) is not restricted by the completed-orders-only
-- definition that caused that gap, and should show real variation even within a
-- group that never successfully converted — some customers tried once, some may
-- have tried and cancelled multiple times before giving up entirely.

WITH customer_span AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_transaction_date,
        COUNT(DISTINCT invoice_no) AS attempt_count
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
)

SELECT
    cbf.customer_id,
    cbf.recency_days,
    cs.first_transaction_date,
    cs.attempt_count,
    CASE
        WHEN cbf.monetary_net IS NULL THEN 'Never Converted'
        ELSE 'Converted'
    END AS conversion_status
FROM uk_retail.customer_behavior_fields cbf
JOIN customer_span cs
    ON cs.customer_id = cbf.customer_id
ORDER BY conversion_status DESC, cbf.recency_days;

-- RESULT (Query 132): 5,875 rows returned. For the 23 Never Converted customers:
-- attempt_count = 1 for 21 of 23 (91.3%); attempt_count = 2 for exactly 2
-- customers (15767, 17632); no never-converted customer has 3+ attempts.
-- Consistent with Query 131's recency/date findings — customer_id 15767 is the
-- only overlap between "made 2 attempts" and "had nonzero active_span_days"
-- from Q131, confirming its 94-day span reflects two genuinely separate attempts,
-- not a data artifact.

-- CONFIRMED FINDING: The never-converted population is overwhelmingly single-attempt:
-- 21 of 23 customers (91%) touched the platform exactly once and never returned,
-- regardless of when that attempt happened. Combined with Query 131's finding that
-- 65% of these attempts cluster in the dataset's first three weeks, the group reads
-- as two distinct failure modes: (1) a launch-window abandonment cohort — tried once
-- near go-live, never returned — and (2) a thin, unclustered tail of one-off
-- abandonments scattered through 2010. attempt_count is confirmed as a usable,
-- non-degenerate third axis for the planned exhibit (values 1-2, versus the
-- uniform NULL/0 seen in frequency_completed and active_span_days).