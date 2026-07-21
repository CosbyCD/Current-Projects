-- Query 133_never_converted_exhibit_data_pull

-- WHAT: Final combined pull for the "Never Converted vs. Everyone Else" 3D exhibit.
-- Pulls recency_days, first_transaction_date, and attempt_count (completed +
-- cancelled invoices) for all 5,875 customers, with a never-converted flag,
-- consolidating the fields confirmed usable in Queries 131 and 132 into the
-- single dataset the exhibit will be built from.

-- WHY: Queries 131 and 132 independently confirmed which fields carry real
-- signal for this population (recency_days, first_transaction_date, attempt_count)
-- and which are degenerate for it (frequency_completed, active_span_days,
-- monetary_net — all NULL/0/undefined for the never-converted group). This query
-- exists as the single source-of-truth pull for the exhibit build itself, rather
-- than reconstructing the join from two separate queries at build time.

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
        WHEN cbf.monetary_net IS NULL THEN TRUE
        ELSE FALSE
    END AS is_never_converted
FROM uk_retail.customer_behavior_fields cbf
JOIN customer_span cs
    ON cs.customer_id = cbf.customer_id
ORDER BY is_never_converted DESC, cbf.recency_days;

-- RESULT (Query 133): 5,875 rows returned, matching Query 132 exactly with
-- is_never_converted as a boolean in place of the text label. 23 TRUE rows,
-- 5,852 FALSE rows. Confirmed clean pass-through — no discrepancies from the
-- prior two queries' outputs.

-- CONFIRMED FINDING: N/A (data-shaping query). Dataset ready for exhibit build.