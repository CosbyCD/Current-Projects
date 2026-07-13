-- ============================================================
-- FOLLOW-UP: Repeated-timestamp invoices — row-level detail
-- WHAT: Pulls full line-item detail for three invoice numbers
--       flagged in query 36 as spanning more than one distinct
--       invoice_date, to see directly what's actually happening
--       on those invoices.
-- WHY: Query 36 found invoice numbers that repeat across
--      multiple timestamps, which could either mean unrelated
--      real activity (e.g., a large order entered over more
--      than one minute) or something that threatens the
--      "dedupe all exact matches" policy for clean_transactions.
--      Confirmed: these are large, multi-line orders (190+
--      distinct stock codes on invoice 494166 alone) where data
--      entry spanned more than sixty seconds, causing the
--      timestamp to roll forward mid-invoice. Every line has a
--      different stock_code, meaning these rows would never
--      trigger the exact-duplicate check in the first place
--      (which requires stock_code, among all other fields, to
--      match). This confirms the dedupe-all policy is safe:
--      large orders spanning multiple timestamps and exact
--      duplicate rows are unrelated phenomena.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE invoice_no IN ('494166', '499967', '500353')
ORDER BY invoice_no, invoice_date;