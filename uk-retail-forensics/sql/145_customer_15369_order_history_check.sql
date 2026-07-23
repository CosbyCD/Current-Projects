-- Query 145_customer_15369_order_history_check
-- WHAT/WHY: characterize customer 15369 (recency 374, freq 11,
-- gross £6,251.26, net £3,346.43, gap £2,904.83 -- 46.5% of gross,
-- cancellation_count 1) from Query 141.

SELECT
    invoice_no, invoice_date, stock_code, description,
    quantity, unit_price, (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '15369'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): 99 line items across 12
-- invoices (11 completed, 1 cancellation). Gross £6,251.26, net
-- £3,346.43, gap £2,904.83 -- all confirm exactly. The single
-- cancellation (C536164, 2010-11-30, 40 line items, -£2,904.83) does
-- NOT match any single completed invoice item-for-item, nor does it
-- match the customer's cumulative total-ever-purchased quantity for
-- any of the 40 stock codes involved -- in every case the cancelled
-- quantity is smaller than the total purchased, consistent with a
-- genuine PARTIAL return across many prior orders rather than a full
-- cancellation of one order. One exception: stock code 75013B ("STRING
-- OF 8 BUTTERFLIES, PINK") was cancelled for 1 unit (-£2.70), but this
-- customer's history shows zero purchases of that item at any point --
-- a small, isolated data anomaly (an item referenced in a return that
-- was never actually bought).

-- CONFIRMED FINDING: Customer 15369's gross/net gap reflects a genuine,
-- consolidated partial-return event -- not a cancelled bulk order like
-- 12346/15749, not a duplicate-cancellation artifact like 13091, and
-- not a reorder-at-discount cycle like 12454. This is a distinct fourth
-- pattern: a real customer who bought across 11 orders over roughly a
-- year and later returned partial quantities of ~40 items in one
-- consolidated transaction -- plausible normal retail return behavior
-- for a small shop adjusting inventory. The £2.70 anomalous line
-- (75013B, never purchased) is flagged as a minor, low-value data
-- inconsistency, immaterial to the overall characterization but
-- consistent with the broader pattern of small data-quality issues
-- surfacing throughout this cancelled/returned-order investigation
-- thread (queries 16077, 119).