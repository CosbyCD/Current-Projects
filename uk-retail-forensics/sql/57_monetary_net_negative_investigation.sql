-- Query 57_monetary_net_negative_investigation

-- ============================================================
-- FOLLOW-UP: Negative monetary_net anomaly — customer 12918
-- WHAT: Pulls the full transaction history for customer 12918,
--       whose monetary_net (-$10,953.50) is exactly the negative
--       mirror of their monetary_gross ($10,953.50) — meaning
--       their cancelled value ($21,907.00) is precisely double
--       their gross purchases.
-- WHY: Query 56 surfaced several customers with this same exact-
--      doubling pattern (16446, 12918, 14802, 15802, 13290),
--      which is too precise to be coincidence. Investigating one
--      case directly, same discipline as the 12,540-quantity
--      outlier in Chapter One, before deciding how the final
--      monetary value field should handle this pattern.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price,
       ROUND((quantity * unit_price)::NUMERIC, 2) AS line_value,
       invoice_date
FROM uk_retail.clean_transactions
WHERE customer_id = '12918'
ORDER BY invoice_date;

-- RESULT: Three rows total, all stock_code "M" ("Manual"), all
-- $10,953.50 in absolute value, spanning 4 minutes on 2010-03-23:
-- C502262 (cancellation, -1 qty, 15:20:00), 502263 (completed charge,
-- +1 qty, 15:22:00), C502264 (cancellation, -1 qty, 15:24:00). The
-- arithmetic confirms the exact-mirror pattern precisely: gross
-- (completed-only) = $10,953.50 (the single 502263 charge); net (all
-- rows) = 10,953.50 - 10,953.50 - 10,953.50 = -$10,953.50; cancelled_
-- value = $21,907.00 (the sum of both cancellation lines), matching
-- Query 56 exactly. Note on structure: the log's narrative describes
-- this as "a manual charge, cancelled, followed immediately by a
-- second identical manual charge, also cancelled" -- language that
-- reads as two charge-then-cancel pairs (4 events). The actual data
-- shows a different structure: TWO cancellation rows bracketing ONE
-- completed charge row, with the first cancellation (15:20:00)
-- chronologically preceding the charge it would need to be cancelling
-- (15:22:00). This is a real discrepancy between the log's
-- characterization and this query's own row-level data, not a
-- rounding or interpretation difference.

-- CONFIRMED FINDING: Confirmed as administrative/manual entries, not
-- real customer purchases -- consistent with the "M" stock code
-- already flagged in Chapter One (Thread 3, Queries 19-23) as a
-- non-numeric administrative code, though that earlier investigation
-- characterized the pattern generally and never built an exclusion
-- rule for it into clean_transactions. The exact-mirror arithmetic is
-- fully explained: two cancellation entries against one real charge
-- produces a net that is the negative of the gross by construction,
-- not coincidence. The precise row-level structure (cancel before
-- charge, then cancel again) doesn't match the log's own narrative
-- description of this customer's history -- worth noting as a
-- discrepancy in this query's documentation, though it doesn't change
-- the underlying conclusion that these are administrative, not
-- customer-facing, entries. This motivates the broader scope check in
-- Query 58: does clean_transactions still contain administrative stock
-- codes generally, not just on this one customer?