-- Query 73_stock_code_23843_description_check

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

-- RESULT: Identical to Query 72 -- the exact same 2 rows, and no
-- others, exist in the untouched raw_transactions table across the
-- full 1,067,371-row dataset. The description ("PAPER CRAFT , LITTLE
-- BIRDIE") reads as a genuine, specific product name, not a
-- placeholder, admin code, or test value -- consistent with a real
-- catalog item, just one that (per this data) was purchased exactly
-- once, by exactly one customer, in the entire two-year dataset
-- window.

-- CONFIRMED FINDING: This rules out the hypothesis that cleaning
-- steps (deduplication, exclusion-table removal, or earlier
-- amendments) had stripped out other legitimate instances of this
-- product -- there were never any others to strip. Stock_code 23843
-- was ordered by exactly one customer, one time, at a genuinely
-- implausible quantity (80,995 units), and self-cancelled twelve
-- minutes later. Combined with the description reading as a real
-- product name rather than an administrative placeholder, this
-- doesn't fit neatly into any exclusion category built so far in this
-- project (not blank/placeholder description, not zero price, not an
-- admin stock code, not missing customer_id) -- it looks exactly like
-- a customer or data-entry mistake on an otherwise real product,
-- structurally similar to the Chapter One 12,540-unit outlier but
-- arrived at through a completely different discovery path (an
-- unexpected row count in a verification query, not a manual scroll).
-- This strengthens the case for treating this specific transaction as
-- a confirmed anomaly requiring exclusion, the same way the Chapter
-- One outlier was handled.