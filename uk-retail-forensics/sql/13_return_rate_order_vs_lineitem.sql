-- Query 13_return_rate_order_vs_lineitem

-- ============================================================
-- DERIVED FIELD: Return rate — order-level vs. line-item-level
-- WHAT: Calculates customer return rate two ways — proportion
--       of ORDERS cancelled, and proportion of LINE ITEMS
--       cancelled — then shows the gap between them per customer.
-- WHY: A single cancelled line item within a large multi-line
--      order looks very different depending on which level you
--      measure at. Building both and comparing, rather than
--      picking one blind, so the difference itself becomes
--      part of the analysis. Sorted by largest gap to surface
--      customers worth a manual row-level check next.
-- ============================================================
WITH order_level AS (
    SELECT
        customer_id,
        invoice_no,
        MAX(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS is_cancelled
    FROM uk_retail.raw_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id, invoice_no
),
order_rate AS (
    SELECT
        customer_id,
        COUNT(*) AS total_orders,
        SUM(is_cancelled) AS cancelled_orders,
        ROUND(SUM(is_cancelled)::NUMERIC / COUNT(*), 4) AS order_level_rate
    FROM order_level
    GROUP BY customer_id
),
line_rate AS (
    SELECT
        customer_id,
        COUNT(*) AS total_line_items,
        SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS cancelled_line_items,
        ROUND(SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 4) AS line_item_rate
    FROM uk_retail.raw_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)
SELECT
    o.customer_id,
    o.total_orders,
    o.cancelled_orders,
    o.order_level_rate,
    l.total_line_items,
    l.cancelled_line_items,
    l.line_item_rate,
    ROUND(o.order_level_rate - l.line_item_rate, 4) AS rate_gap
FROM order_rate o
JOIN line_rate l ON o.customer_id = l.customer_id
ORDER BY ABS(o.order_level_rate - l.line_item_rate) DESC;

-- RESULT: Result set spans the full customer base, sorted by absolute
-- gap between the two measures. At the top of the list, gaps of
-- 0.55-0.67 are common — e.g. customer 16118.0: order_level_rate=0.8000
-- (5 orders, 4 cancelled) vs. line_item_rate=0.1277 (47 line items, only
-- 6 cancelled), a 0.6723 gap. This pattern — a handful of orders, most
-- of them cancellation invoices, but each cancellation invoice
-- containing very few line items relative to the customer's regular
-- orders — recurs across the highest-gap rows throughout the result.
-- Nearly all gaps in the full sorted list are positive (order_level_rate
-- higher), confirming line-item-level consistently dampens the
-- appearance of return behavior for customers whose cancellation
-- invoices are smaller than their typical order. A small number of
-- customers (15935.0, 15369.0, 15461.0) show the reverse: NEGATIVE gaps
-- (line_item_rate exceeds order_level_rate) — meaning for these specific
-- customers, their cancellation invoice(s) contained unusually MANY line
-- items relative to their normal order size (e.g. 15461.0: only 3
-- orders total, 1 cancelled = 0.3333 order-level, but that one
-- cancelled invoice contained 3 of the customer's 5 total line items,
-- producing a 0.6000 line-item rate). These three inverse cases are
-- worth a manual row-level check, per this query's own stated purpose,
-- since they represent the opposite failure mode from the general
-- pattern.

-- CONFIRMED FINDING: Order-level and line-item-level return rate are
-- confirmed to diverge substantially and systematically for a large
-- share of the customer base, not just a few edge cases — this closes
-- the comparison Query 11/12 set out to make. The dominant pattern
-- (positive gap, order-level higher) reflects cancellation invoices
-- that are typically SMALLER than a customer's regular orders — a
-- customer might cancel entire small top-up orders while their large
-- orders go through intact, which order-level rate overstates as "this
-- customer returns a lot" when line-item-level shows the return volume
-- is actually modest. The rarer negative-gap cases point to the
-- opposite real behavior — a large cancelled order sitting alongside
-- otherwise minimal activity. Recommendation stands from Query 12:
-- line-item-level is the more defensible default for
-- customer_behavior_fields, since it reflects actual return volume; this
-- query's gap column is itself worth preserving as a diagnostic/QA
-- field rather than discarding, since large positive or negative gaps
-- flag customers whose return behavior the single chosen metric might
-- misrepresent. The blank-customer_id anomaly from Query 11 was not
-- checked against in this pass — still an open, deferred item per this
-- project's plan to address it once further into the customer-id-
-- dependent build (Queries 45+).