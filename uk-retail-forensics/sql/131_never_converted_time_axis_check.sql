-- Query 131_never_converted_time_axis_check

-- WHAT: Pulls recency_days, frequency_completed (order-attempt count, including
-- cancelled-only history), and a tenure/time-cohort measure (first transaction
-- date and days-active span, first-touch to last-touch) for all 5,875 customers,
-- flagged as Never Converted vs. Converted using the same monetary_net IS NULL
-- signature confirmed in Query 130. Never-converted customers are excluded from
-- monetary_net entirely (that NULL is what caused the Q130 tier-leakage bug),
-- so this query substitutes time-based fields as the third axis candidate in
-- place of spend for a planned "never converted vs. everyone else" 3D exhibit.

-- WHY: Query 130 confirmed WHO the 23 never-converted customers are and WHY they
-- were being mislabeled, but never characterized WHERE they sit relative to the
-- rest of the population on any axis other than recency/frequency. Money is not
-- a usable third axis for this group (uniformly null). This project's Nov 2010
-- cohort finding (Chapter Three) was surfaced by looking at *when* activity
-- happened, not just how much — this query tests whether the same kind of
-- timing signal separates the never-converted group, before committing to
-- building an exhibit around it.

WITH customer_span AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_transaction_date,
        MAX(invoice_date) AS last_transaction_date,
        (MAX(invoice_date)::date - MIN(invoice_date)::date) AS active_span_days
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
)

SELECT
    cbf.customer_id,
    cbf.recency_days,
    cbf.frequency_completed,
    cs.first_transaction_date,
    cs.last_transaction_date,
    cs.active_span_days,
    CASE
        WHEN cbf.monetary_net IS NULL THEN 'Never Converted'
        ELSE 'Converted'
    END AS conversion_status
FROM uk_retail.customer_behavior_fields cbf
JOIN customer_span cs
    ON cs.customer_id = cbf.customer_id
ORDER BY conversion_status DESC, cbf.recency_days;

-- RESULT: 5,875 rows returned (23 Never Converted, 5,852 Converted). For the
-- 23 Never Converted rows: frequency_completed is NULL for all 23; active_span_days
-- is 0 for 22 of 23 (single-touch customers), with one exception — customer 15767,
-- span of 94 days (2009-12-04 to 2010-03-08). first_transaction_date shows a clear
-- non-random pattern: 15 of 23 (65%) fall between 2009-12-01 and 2009-12-22 —
-- the dataset's first three weeks. The remaining 8 are single, isolated attempts
-- scattered from 2010-03-08 through 2010-12-02, roughly one every 1-2 months,
-- with no secondary clustering.

-- CONFIRMED FINDING: The 23 never-converted customers are not randomly distributed
-- in time. 15 of 23 (65%) made their sole transaction attempt within the first
-- three weeks of the dataset (Dec 1-22, 2009), consistent with an early-platform
-- abandonment cohort rather than steady-state churn. The remaining 8 are isolated
-- single-attempt cancellations spread across 2010 with no clustering. Both
-- frequency_completed and active_span_days are degenerate for this group (NULL
-- or 0 for all but one customer) and are not viable exhibit axes. first_transaction_date
-- is the only field carrying real separating signal — recommended as the time
-- axis for the planned Never Converted exhibit, paired with a raw order-attempt
-- count (completed + cancelled) rather than frequency_completed, since that field
-- excludes this group entirely by definition. See Query 132 for the attempt-count pull.

-- [CORRECTION — verified July 22, 2026: the CONFIRMED FINDING states
-- "15 of 23 (65%)" of never-converted customers cluster in the dataset's
-- first three weeks (Dec 1-22, 2009). Direct count against the pasted
-- data gives 14 of 23 (60.9%). Customer 13749 (first transaction
-- 2010-01-07) was miscounted into this cluster; it belongs in the
-- "remaining" group instead. The remaining group is therefore 9
-- customers, not 8, spanning 2010-01-07 through 2010-12-02 — not
-- "2010-03-08 through 2010-12-02" as originally stated.]