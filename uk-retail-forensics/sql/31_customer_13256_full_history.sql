-- Query 31_customer_13256_full_history

-- ============================================================
-- FOLLOW-UP: Customer 13256 — full isolated history
-- WHAT: Pulls every transaction on record for customer_id
--       13256, independent of stock_code, to confirm there is
--       nothing else on this account that changes the picture
--       established by Queries 29 and 30.
-- WHY: Query 29 confirmed the 12,540-unit row is an outlier
--      relative to product 84826's normal order pattern. Query
--      30 ruled out a transposition/inversion explanation via
--      nearby customer_ids. This is the final direct check:
--      pull customer 13256's own complete history in isolation
--      to confirm the single flagged row is genuinely all there
--      is on this account, not one row among others that would
--      give more context.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE customer_id = '13256.0'
ORDER BY invoice_date;

-- RESULT: Exactly one row returned -- invoice 578841, stock_code 84826
-- ("ASSTD DESIGN 3D PAPER STICKERS"), quantity 12,540, unit_price
-- £0.00, dated 2011-11-25 -- confirming precisely what Query 29 already
-- showed when it pulled this customer's rows as part of the broader
-- stock_code/customer_id combined check. No other invoices, no other
-- products, no other dates exist for this customer_id anywhere in the
-- dataset.

-- CONFIRMED FINDING: Customer 13256 has no transaction history beyond
-- the single flagged anomalous row. This closes the investigation
-- opened in Query 28 with full confidence: the 12,540-unit, zero-price
-- row is confirmed isolated on both sides -- abnormal relative to the
-- product's own history (Query 29) and unexplained by any neighboring
-- customer_id pattern (Query 30) -- with this final check confirming
-- there is no additional context anywhere on the customer's own record
-- that would reframe the anomaly. The recommendation from Query 29
-- stands unchanged and is now fully corroborated: this single row
-- should be excluded or corrected before customer_id 13256 is included
-- in any customer-behavior-field calculation, since as it stands this
-- one unverifiable row is the customer's entire recorded history. This
-- closes the 28-31 outlier investigation thread.