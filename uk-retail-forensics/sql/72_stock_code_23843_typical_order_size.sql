-- Query 72_stock_code_23843_typical_order_size

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

-- RESULT: Only 2 rows exist for stock_code 23843 in the entire
-- clean_transactions table -- the 80,995-unit purchase and its own
-- exact-match cancellation. No other order for this product exists at
-- any quantity, meaning there is no genuine "typical order size" to
-- compare against at all -- unlike the Chapter One outlier (Query 29,
-- stock_code 84826), where dozens of other orders established a clear
-- normal range (mostly 60-unit case orders). Here, the comparison
-- method itself returns nothing to compare with.

-- CONFIRMED FINDING: The absence of any other order for this product
-- is itself the finding -- it means 80,995 units cannot be validated
-- as plausible by comparison, the way the earlier outlier was ruled
-- implausible by comparison. This is a different and in some ways
-- more concerning situation than the Chapter One case: there, dozens
-- of legitimate orders proved what normal looked like, making the
-- outlier obviously wrong. Here, there's no normal to measure against
-- at all -- stock_code 23843 exists in this dataset for exactly one
-- customer, one moment, one implausibly large quantity, immediately
-- self-reversed. Whether this reflects a genuine, if extreme, single
-- customer action or a data entry error remains open pending further
-- characterization -- worth checking the product's description and
-- unit price for internal plausibility (e.g. does £2.08 x 80,995
-- units make sense for whatever this product actually is) before
-- deciding how to handle it.