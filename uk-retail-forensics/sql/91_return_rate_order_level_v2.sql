-- Query 91_return_rate_order_level_v2

-- ============================================================
-- CHAPTER TWO, FIELD 6: Return Rate — order-level (rebuild)
-- WHAT: Recalculates order-level return rate per customer —
--       cancelled orders divided by total orders — against
--       clean_transactions, following the same methodology
--       established in Chapter One (query 11) but built against
--       raw_transactions at the time.
-- WHY: Sixth and final of the six derived customer behavior
--      fields. The methodology decision (order-level vs.
--      line-item-level, both tracked) was already made and
--      compared in Chapter One; this rebuild applies it to the
--      clean, fully reconciled table rather than repeating the
--      investigation.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%') AS cancelled_orders,
    COUNT(DISTINCT invoice_no) AS total_orders,
    ROUND(100.0 * COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(DISTINCT invoice_no), 1) AS order_return_rate_pct
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY order_return_rate_pct DESC;

-- RESULT: 5,875 rows -- the full current customer population, since
-- every customer has at least one order by definition and this field
-- applies no completed-only filter. Sorted descending by return rate,
-- the top of the list is dominated by low-volume customers hitting
-- exactly 100% (e.g. 1 cancelled of 1 total order) -- the same
-- small-n dominance pattern already flagged in Chapter One (Query 13)
-- when order-level and line-item-level rates were first compared.

-- CONFIRMED FINDING: Order-level return rate is successfully rebuilt
-- against the fully reconciled clean_transactions table, applying the
-- methodology already established and compared in Chapter One rather
-- than re-litigating the order-level-vs-line-item question. This is
-- the sixth and final of the six core derived customer behavior
-- fields. Consistent with the small-n distortion already documented
-- in Chapter One, this field will need the line-item-level comparison
-- (next query) before either is trusted as the primary return-rate
-- measure for low-volume customers.