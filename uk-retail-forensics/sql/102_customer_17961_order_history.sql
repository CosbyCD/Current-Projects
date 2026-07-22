-- Query 102_customer_17961_order_history

-- ============================================================
-- INVESTIGATION: Customer 17961 — order-level history pull
-- WHAT: Pulls full order-level detail (invoice_date, stock_code,
--       quantity, unit_price) for customer 17961, whose average
--       order value (~£24) is anomalously low relative to peers
--       at the same monetary_gross rank (4673rd, £2,866.74,
--       ~120 completed orders, 20-day recency).
-- WHY: Surfaced via hover tooltip while rotating the 3D RFM
--      chart. Method-honesty assessment (Sprint 6) noted this
--      anomaly would have been found faster via a simple
--      monetary_gross/frequency_completed ratio query — this
--      pull is the follow-up to determine root cause: habitual
--      small-basket buying, a wholesale/reseller pattern, or a
--      data quality issue.
-- ============================================================
SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '17961'
ORDER BY invoice_date, invoice_no;

-- RESULT: 632 line items across 102 distinct invoices (100
-- completed, 2 cancelled), spanning 2009-12-01 to 2011-11-18.
-- Summed monetary_gross across the 100 completed invoices =
-- £2,866.74, exactly matching the figure cited in the WHAT block.
-- However, dividing by the actual completed-order count of 100
-- gives an average order value of £28.67, not the "~£24" figure
-- the WHAT block implies — that number appears to have been
-- back-calculated using an order count of ~120, which does not
-- match this pulled data (100 completed invoices, confirmed by
-- direct count). Basket size per order ranges from 1 to 61 line
-- items (avg 6.3), with order totals ranging from £1.25 to
-- £396.85 (median £13.65). The largest single order (invoice
-- 490312, 61 line items, £326.13) is heavy on low-unit-price
-- novelty/craft items (pencils, erasers, trinket boxes, candle
-- holders) rather than bulk quantities of few SKUs.

-- CONFIRMED FINDING: Customer 17961's low average order value is
-- explained by habitual small-basket, low-unit-price purchasing —
-- median order value £13.65, dominated by sub-£3 novelty and craft
-- items — not a wholesale/reseller pattern (no evidence of bulk
-- single-SKU orders) and not a data quality issue (the monetary
-- total reconciles exactly against customer_behavior_fields). This
-- write-up flags an unresolved discrepancy in the WHAT block's own
-- framing: the ~120-order figure and ~£24 average order value do
-- not match the actual pulled data (100 completed orders, £28.67
-- average), and should not be repeated in the Tableau workbook or
-- any downstream documentation without checking which figure
-- (~120 or 100) frequency_completed actually holds for this
-- customer in customer_behavior_fields.