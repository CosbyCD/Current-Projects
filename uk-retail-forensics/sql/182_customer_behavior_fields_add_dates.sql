-- Query 182_customer_behavior_fields_add_dates

-- ============================================================
-- REVISION OF QUERY 94: Adding first_purchase_date and last_order_date
-- WHAT: Rebuilds uk_retail.customer_behavior_fields from scratch,
--       identical to Query 94 in every respect, with one addition:
--       a new `dates` CTE contributing first_purchase_date
--       (MIN invoice_date) and last_order_date (MAX invoice_date)
--       per customer, both from an unconditional clean_transactions
--       scan (no invoice_no filter — same convention as the existing
--       `recency` CTE).
-- WHY: The Nov 2010 Cohort Tableau worksheets (Lifecycle, Acquisition
--      Month x2, Last-Order Timing) need raw first-purchase and
--      last-order dates to bucket customers the same way the
--      corresponding exhibit HTML files already do (built from
--      Query 181's CSV pull). customer_behavior_fields had no such
--      columns — Query 94 built it from six behavior fields, none
--      of which carry these raw dates. Per this project's standing
--      rule (Query 94 and its predecessors 24/38/59/74), this table
--      has always been rebuilt fresh via DROP + CREATE TABLE AS
--      rather than patched with ALTER TABLE, so this revision
--      follows that same precedent rather than introducing a new
--      pattern.
--
--      Deriving last_order_date from the same unconditional scan
--      used by the `recency` CTE (no invoice_no NOT LIKE 'C%'
--      filter) is deliberate: it guarantees last_order_date is
--      internally consistent with recency_days by construction
--      (reference_date - last_order_date = recency_days, exactly),
--      rather than requiring a separate reconciliation check.
-- ============================================================
DROP TABLE IF EXISTS uk_retail.customer_behavior_fields;

CREATE TABLE uk_retail.customer_behavior_fields AS
WITH recency AS (
    SELECT customer_id,
        EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM uk_retail.clean_transactions) - MAX(invoice_date))::INT AS recency_days
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
dates AS (
    SELECT customer_id,
        MIN(invoice_date) AS first_purchase_date,
        MAX(invoice_date) AS last_order_date
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
frequency AS (
    SELECT a.customer_id, a.frequency_completed, (b.frequency_all - a.frequency_completed) AS cancellation_count
    FROM (SELECT customer_id, COUNT(DISTINCT invoice_no) AS frequency_completed FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%' GROUP BY customer_id) a
    JOIN (SELECT customer_id, COUNT(DISTINCT invoice_no) AS frequency_all FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL GROUP BY customer_id) b
    ON a.customer_id = b.customer_id
),
monetary AS (
    SELECT a.customer_id, a.monetary_gross, b.monetary_net
    FROM (SELECT customer_id, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_gross FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%' GROUP BY customer_id) a
    JOIN (SELECT customer_id, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_net FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL GROUP BY customer_id) b
    ON a.customer_id = b.customer_id
),
interval_data AS (
    WITH order_dates AS (
        SELECT DISTINCT customer_id, invoice_no, MIN(invoice_date) AS order_date
        FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%'
        GROUP BY customer_id, invoice_no
    ), gaps AS (
        SELECT customer_id,
            EXTRACT(DAY FROM order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS whole_gap,
            EXTRACT(EPOCH FROM order_date - LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date))/86400.0 AS frac_gap
        FROM order_dates
    )
    SELECT customer_id, ROUND(AVG(whole_gap)::NUMERIC,1) AS avg_interval_whole_day, ROUND(AVG(frac_gap)::NUMERIC,2) AS avg_interval_fractional_day
    FROM gaps WHERE whole_gap IS NOT NULL GROUP BY customer_id
),
diversity AS (
    SELECT customer_id,
        COUNT(DISTINCT stock_code) AS distinct_variants_purchased,
        COUNT(DISTINCT REGEXP_REPLACE(stock_code, '[A-Za-z]+$', '')) AS distinct_families_purchased
    FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%'
    GROUP BY customer_id
),
returns AS (
    SELECT a.customer_id, a.order_return_rate_pct, b.line_item_return_rate_pct
    FROM (SELECT customer_id, ROUND(100.0*COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%')/COUNT(DISTINCT invoice_no),1) AS order_return_rate_pct FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL GROUP BY customer_id) a
    JOIN (SELECT customer_id, ROUND(100.0*COUNT(*) FILTER (WHERE invoice_no LIKE 'C%')/COUNT(*),1) AS line_item_return_rate_pct FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL GROUP BY customer_id) b
    ON a.customer_id = b.customer_id
)
SELECT r.customer_id, r.recency_days,
    dt.first_purchase_date, dt.last_order_date,
    f.frequency_completed, f.cancellation_count,
    m.monetary_gross, m.monetary_net,
    i.avg_interval_whole_day, i.avg_interval_fractional_day,
    d.distinct_variants_purchased, d.distinct_families_purchased,
    ret.order_return_rate_pct, ret.line_item_return_rate_pct
FROM recency r
LEFT JOIN dates dt ON r.customer_id = dt.customer_id
LEFT JOIN frequency f ON r.customer_id = f.customer_id
LEFT JOIN monetary m ON r.customer_id = m.customer_id
LEFT JOIN interval_data i ON r.customer_id = i.customer_id
LEFT JOIN diversity d ON r.customer_id = d.customer_id
LEFT JOIN returns ret ON r.customer_id = ret.customer_id
ORDER BY r.customer_id;

-- RESULT: Query executed successfully — 5,875 rows, exact match to
-- Query 94's population (row count unaffected; only columns added).
-- Row count independently confirmed via SELECT COUNT(*), July 26, 2026:
-- 5,875, matching Query 94 exactly.
-- Two further checks were run as their own separate, saved queries,
-- per this project's standing practice of not folding verification into
-- unlogged ad hoc checks (see Query 97's precedent, independently
-- re-confirming Query 96 as its own numbered query):
--   - Query 183 (dates_consistency_check): confirms last_order_date is
--     internally consistent with recency_days, spot-checked against
--     customer 16754. Passed.
--   - Query 184 (dates_null_check): confirms zero NULLs across both new
--     columns for all 5,875 customers. Passed.

-- CONFIRMED FINDING: uk_retail.customer_behavior_fields has been rebuilt
-- (DROP + CREATE TABLE AS, per this table's established rebuild precedent —
-- Queries 24, 38, 59, 74, 94) with two new columns, first_purchase_date and
-- last_order_date, added alongside all twelve fields from Query 94 unchanged.
-- Row count held at 5,875; Queries 183 and 184 independently confirm the new
-- columns are internally consistent with recency_days and fully populated
-- with zero NULLs, respectively. This table is now a valid source for the
-- Nov 2010 Cohort Tableau worksheets requiring first-purchase or last-order
-- date bucketing (Lifecycle, Acquisition Month — Bucketed, Acquisition
-- Month — Gradient, Last-Order Timing).