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