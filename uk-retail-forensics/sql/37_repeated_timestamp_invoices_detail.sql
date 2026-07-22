-- Query 37_repeated_timestamp_invoices_detail

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

-- RESULT: Confirms the hypothesis directly. Invoice 494166 alone
-- contains 190+ distinct line items, every one a different stock_code,
-- with invoice_date holding steady at "2010-01-12 09:47:00" through the
-- bulk of the order before rolling forward to "2010-01-12 09:48:00" for
-- the final ~15 lines -- a one-minute clock tick partway through a
-- single large manual data-entry session, not two separate events.
-- Invoices 499967 (customer 16636.0, ~30 line items, timestamps
-- 14:06:00 rolling to 14:07:00) and 500353 (customer 12668.0, 100+ line
-- items, timestamps 15:24:00 rolling to 15:25:00) show the identical
-- pattern: one large order, one customer, one coherent shopping
-- session, with the invoice_date ticking forward mid-entry purely as a
-- side effect of how long it took to key in that many line items.
-- Critically, no stock_code repeats within any of the three invoices --
-- every line item is genuinely distinct, meaning none of these rows
-- could ever satisfy the exact-duplicate match criteria from Queries
-- 17-18 (which require invoice_no, stock_code, description, quantity,
-- unit_price, customer_id, AND invoice_date to all match simultaneously).

-- CONFIRMED FINDING: The invoice-number/multi-timestamp pattern found
-- in Query 36 is fully explained and resolved: these are large,
-- legitimate multi-line customer orders where manual data entry simply
-- took long enough to cross a one-minute clock boundary, not duplicate
-- or conflicting invoice activity. This confirms the "dedupe all
-- exact-match rows" policy established in Queries 17-18 remains fully
-- safe to apply -- large orders spanning multiple timestamps and true
-- exact-duplicate rows are two unrelated phenomena that cannot overlap,
-- since a genuine duplicate requires the same stock_code to repeat
-- under identical conditions, which never happens within these
-- multi-line orders. This closes the invoice-number-uniqueness
-- investigation thread (36-37) with full confidence heading into the
-- clean_transactions build.