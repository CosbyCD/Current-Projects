-- ============================================================
-- FOLLOW-UP: Verify the 80,995-unit quantity against typical
--            order sizes for stock_code 23843
-- WHAT: Pulls every order for "PAPER CRAFT, LITTLE BIRDIE"
--       (stock_code 23843) across the full clean_transactions
--       table, to see whether 80,995 units is a plausible order
--       size or a clear outlier, the same way the 12,540-unit
--       outlier was verified in Chapter One (query 29).
-- WHY: Customer 16446's entire gross monetary value is
--      essentially this one transaction. If 80,995 is wildly
--      outside this product's normal order range, this is a
--      new, previously-undetected data entry error — one that
--      slipped past every exclusion rule built so far because
--      it has a real stock code, real invoice number, and a
--      properly-flagged 'C'-prefix cancellation.
-- ============================================================
SELECT invoice_no, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.clean_transactions
WHERE stock_code = '23843'
ORDER BY quantity DESC
LIMIT 20;