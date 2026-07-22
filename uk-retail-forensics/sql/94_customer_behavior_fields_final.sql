-- Query 94_customer_behavior_fields_final

-- ============================================================
-- CHAPTER TWO: Final customer behavior fields table
-- WHAT: Joins all six derived customer behavior fields into
--       one table, one row per customer, built entirely from
--       clean_transactions.
-- WHY: This is the direct input table for the eventual 3D
--      visualization. Every component field was independently
--      built, verified, and in several cases rebuilt against
--      an amended source table over the course of this chapter.
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
    f.frequency_completed, f.cancellation_count,
    m.monetary_gross, m.monetary_net,
    i.avg_interval_whole_day, i.avg_interval_fractional_day,
    d.distinct_variants_purchased, d.distinct_families_purchased,
    ret.order_return_rate_pct, ret.line_item_return_rate_pct
FROM recency r
LEFT JOIN frequency f ON r.customer_id = f.customer_id
LEFT JOIN monetary m ON r.customer_id = m.customer_id
LEFT JOIN interval_data i ON r.customer_id = i.customer_id
LEFT JOIN diversity d ON r.customer_id = d.customer_id
LEFT JOIN returns ret ON r.customer_id = ret.customer_id
ORDER BY r.customer_id;

-- RESULT: Table created successfully — 5,875 rows, one per distinct
-- customer_id in clean_transactions. Structure: customer_id plus
-- 11 fields across six dimensions (recency, frequency, monetary,
-- interval, product diversity, return rate), matching the six
-- independently-built and verified component fields from Queries
-- 45-93. Because recency is the anchor CTE and is built from an
-- unconditional customer_id scan (no invoice-type filter), the
-- 5,875 count represents every customer with at least one row in
-- clean_transactions, cancellation-only customers included. All
-- other fields are LEFT JOINed onto that base, so any customer
-- whose activity doesn't satisfy a component CTE's WHERE clause
-- (e.g. a customer with only cancelled invoices, which the
-- frequency and interval CTEs exclude via invoice_no NOT LIKE 'C%')
-- will carry NULLs in that field rather than zeros.

-- CONFIRMED FINDING: customer_behavior_fields is finalized at 5,875
-- customers × 11 fields, built entirely from clean_transactions with
-- no additional filtering beyond each component field's own logic.
-- This confirms the table matches the target structure for the
-- downstream 3D visualization. Note for later use of this table:
-- NULLs in frequency/interval/diversity fields are structurally
-- expected for cancellation-only customers, not missing data, and
-- should not be treated as a data quality flag without checking
-- whether the customer_id in question falls into that category.