-- Query 156_stock_interval

-- WHAT: Fourth field of stock_behavior_fields: average days between
--       successive completed orders containing this SKU (across all
--       customers), both whole-day and fractional-day versions.
--       Mirrors the customer-side interval build exactly (Query
--       85-88): LAG-based gap calculation between consecutive order
--       dates for the same SKU.
-- WHY: On the customer side, interval measured a single customer's
--      natural reordering rhythm. On the stock side, this measures
--      the SKU's own natural demand cadence -- how often, on average,
--      does ANY order for this item land -- which is the direct
--      "restocking rhythm" signal Phase 4's headline finding needs.
--      Both whole-day and fractional-day versions built per the
--      customer-side precedent (Query 87-88 found real intra-day gaps
--      the whole-day version rounds to zero).

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
ORDER BY stock_code;

-- RESULT (verified against pasted CSV): 4,598 rows. The 123-row gap
-- from Query 154's 4,721-SKU population matches EXACTLY the set of
-- SKUs with frequency_completed = 1 (single completed order, no gap
-- computable) -- confirmed with zero unexpected exclusions. Interval
-- range: 0.0 to 489.0 days (whole-day). 34 SKUs show
-- avg_interval_whole_day = 0.0 -- the same intra-day-gap-rounds-to-zero
-- phenomenon first identified on the customer side (customer 18139,
-- Query 87), confirming the fractional-day fork remains necessary here.

-- CONFIRMED FINDING: Stock-side interval is built and verified for
-- 4,598 SKUs with 2+ completed orders. This field is the direct
-- "restocking rhythm" signal for Phase 4's velocity-vs-lifetime-average
-- headline finding -- a SKU whose recent gap since last sale
-- (recency_days, Query 153) significantly exceeds its own historical
-- avg_interval is the concrete "overdue" signal this sprint is built to
-- surface.

-- [ADDENDUM] This query was run against full_transactions before the
-- double-counting bug (confirmed and fixed at Queries 151b/151c/151d)
-- was corrected. Structurally reasoned to be unaffected: the order_dates
-- CTE is built on SELECT DISTINCT stock_code, invoice_no -- duplicating
-- a row cannot manufacture a new distinct (stock_code, invoice_no) pair,
-- and MIN(invoice_date) for that pair is unaffected by duplicates, the
-- same reasoning that held for Queries 153 and 154. Independently
-- confirmed by rerunning this exact query against the corrected
-- full_transactions and diffing the two outputs directly: 4,598 rows in
-- both runs, identical stock_code sets, zero value differences across
-- avg_interval_whole_day and avg_interval_fractional_day. Not an
-- assumption -- verified, same standard applied as Queries 153 and 154.