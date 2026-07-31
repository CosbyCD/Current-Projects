-- Query 159_build_stock_behavior_fields

-- WHAT: Assembles the final stock_behavior_fields table, one row per
--       stock_code, joining all six individually-verified fields
--       (recency, frequency, monetary, interval, demand breadth,
--       return rate) from queries 153-158. Mirrors the customer-side
--       assembly (Query 94) exactly: recency is the anchor (full
--       4,734-SKU population, no exclusions), all other fields LEFT
--       JOINed on so structurally-absent SKUs (the 13 cancellation-
--       only items, the 103 unattributed-only items) carry NULLs
--       rather than being dropped.
-- WHY: Consolidates the six independently-verified fields into a
--      single reference table for Phase 4's headline findings, the
--      same role customer_behavior_fields plays for the customer side.
--      Anchoring on recency (rather than an INNER JOIN across all six)
--      preserves the full population per this project's segregate-
--      don't-delete standard -- structurally NULL fields are
--      informative (cancellation-only, unattributed-only) not missing
--      data to be discarded.

-- [PROVENANCE NOTE, added during the July 31, 2026 forensic review pass]
-- The original version of this file was overwritten and is not
-- recoverable. The query below is a RECONSTRUCTION, assembled by
-- joining the six already-independently-verified field queries
-- (153-158) using the same LEFT JOIN-on-recency pattern documented in
-- this file's own WHY block and confirmed against Query 94's
-- customer-side precedent. It has not been checked against the
-- original file, because the original no longer exists. Flagged
-- explicitly per this project's standing rule against treating
-- reconstructed content as equivalent to verified original work --
-- this should be read as "rebuilt from confirmed components," not
-- "recovered." It becomes the authoritative version of Query 159 going
-- forward once run and confirmed below.

DROP TABLE IF EXISTS uk_retail.stock_behavior_fields;

CREATE TABLE uk_retail.stock_behavior_fields AS
WITH recency AS (
    SELECT
        stock_code,
        EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM uk_retail.full_transactions) - MAX(invoice_date))::INT AS recency_days
    FROM uk_retail.full_transactions
    GROUP BY stock_code
),
frequency AS (
    SELECT
        a.stock_code,
        a.frequency_completed,
        b.frequency_all,
        (b.frequency_all - a.frequency_completed) AS cancellation_count
    FROM (
        SELECT stock_code, COUNT(DISTINCT invoice_no) AS frequency_completed
        FROM uk_retail.full_transactions
        WHERE invoice_no NOT LIKE 'C%'
        GROUP BY stock_code
    ) a
    JOIN (
        SELECT stock_code, COUNT(DISTINCT invoice_no) AS frequency_all
        FROM uk_retail.full_transactions
        GROUP BY stock_code
    ) b ON a.stock_code = b.stock_code
),
monetary AS (
    SELECT
        a.stock_code,
        a.monetary_gross,
        b.monetary_net
    FROM (
        SELECT stock_code, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_gross
        FROM uk_retail.full_transactions
        WHERE invoice_no NOT LIKE 'C%'
        GROUP BY stock_code
    ) a
    JOIN (
        SELECT stock_code, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_net
        FROM uk_retail.full_transactions
        GROUP BY stock_code
    ) b ON a.stock_code = b.stock_code
),
interval_field AS (
    WITH order_dates AS (
        SELECT DISTINCT stock_code, invoice_no, MIN(invoice_date) AS order_date
        FROM uk_retail.full_transactions
        WHERE invoice_no NOT LIKE 'C%'
        GROUP BY stock_code, invoice_no
    ),
    gaps AS (
        SELECT stock_code,
            EXTRACT(DAY FROM order_date - LAG(order_date) OVER (PARTITION BY stock_code ORDER BY order_date)) AS whole_gap,
            EXTRACT(EPOCH FROM order_date - LAG(order_date) OVER (PARTITION BY stock_code ORDER BY order_date))/86400.0 AS frac_gap
        FROM order_dates
    )
    SELECT stock_code,
        ROUND(AVG(whole_gap)::NUMERIC,1) AS avg_interval_whole_day,
        ROUND(AVG(frac_gap)::NUMERIC,2) AS avg_interval_fractional_day
    FROM gaps
    WHERE whole_gap IS NOT NULL
    GROUP BY stock_code
),
demand_breadth AS (
    SELECT
        stock_code,
        COUNT(DISTINCT customer_id) AS distinct_customers
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
      AND invoice_no NOT LIKE 'C%'
    GROUP BY stock_code
),
return_rate AS (
    SELECT
        a.stock_code,
        a.order_return_rate_pct,
        b.line_item_return_rate_pct
    FROM (
        SELECT stock_code,
            ROUND(100.0*COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%')/COUNT(DISTINCT invoice_no),1) AS order_return_rate_pct
        FROM uk_retail.full_transactions
        GROUP BY stock_code
    ) a
    JOIN (
        SELECT stock_code,
            ROUND(100.0*COUNT(*) FILTER (WHERE invoice_no LIKE 'C%')/COUNT(*),1) AS line_item_return_rate_pct
        FROM uk_retail.full_transactions
        GROUP BY stock_code
    ) b ON a.stock_code = b.stock_code
)
SELECT
    r.stock_code,
    r.recency_days,
    f.frequency_completed,
    f.frequency_all,
    f.cancellation_count,
    m.monetary_gross,
    m.monetary_net,
    i.avg_interval_whole_day,
    i.avg_interval_fractional_day,
    d.distinct_customers,
    rr.order_return_rate_pct,
    rr.line_item_return_rate_pct
FROM recency r
LEFT JOIN frequency f ON r.stock_code = f.stock_code
LEFT JOIN monetary m ON r.stock_code = m.stock_code
LEFT JOIN interval_field i ON r.stock_code = i.stock_code
LEFT JOIN demand_breadth d ON r.stock_code = d.stock_code
LEFT JOIN return_rate rr ON r.stock_code = rr.stock_code
ORDER BY r.stock_code;

-- RESULT: table created successfully -- 4,734 rows, confirmed via
-- SELECT 4734, matching the full stock recency population from Query
-- 153 exactly. Like queries 38, 59, 74, and 94 before it, this is a
-- DROP TABLE + CREATE TABLE AS statement with no exportable result set
-- to diff column-by-column -- the row count is the direct verification
-- here, same as those precedents.

-- CONFIRMED FINDING: stock_behavior_fields is finalized at 4,734 SKUs
-- x 11 fields (12 columns including stock_code) across six dimensions
-- (recency, frequency, monetary, interval, demand breadth, return
-- rate), mirroring customer_behavior_fields' structure. Built from the
-- reconstructed query above (see provenance note) against the
-- CORRECTED full_transactions (post Query 151d) and the corrected
-- line_item_return_rate_pct (post Query 158's rerun) -- this table has
-- never been exposed to the double-counting bug at any point, since it
-- was built fresh after the fix. This is now the authoritative source
-- for Chapter Five's headline findings. The 572/93/108 figures
-- (Overdue Restock / Seasonal Dormant / Dead Stock) previously reported
-- were built against the OLD, buggy stock_behavior_fields and are not
-- yet re-verified against this corrected table -- that re-verification
-- is the next step, not yet done.

-- Schema independently confirmed via pgAdmin's table browser: 12
-- columns exactly as expected (stock_code text, then the 11 numeric/
-- bigint fields in the same order as this query's SELECT list) --
-- direct structural confirmation that the reconstruction actually
-- matches what was built, not just an inference from the row count.