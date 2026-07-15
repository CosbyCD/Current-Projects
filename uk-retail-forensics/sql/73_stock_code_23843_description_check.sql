-- ============================================================
-- FOLLOW-UP: Confirm stock_code 23843 is a genuine product,
--            not a test/phantom code
-- WHAT: Checks the description associated with stock_code 23843
--       and whether it appears anywhere in raw_transactions
--       (not just clean_transactions) beyond these same two rows.
-- WHY: Query 72 found only 2 rows exist for this stock code in
--      the entire clean table — no other customer has ever
--      ordered it. Before concluding this is a data entry error
--      versus a legitimately rare/new product, worth confirming
--      whether the raw source data shows any other trace of it.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE stock_code = '23843'
ORDER BY invoice_date;