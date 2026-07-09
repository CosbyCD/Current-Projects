-- ============================================================
-- FOLLOW-UP: Customer 13256 — full history, direct confirmation
-- WHAT: Pulls every transaction on record for customer_id 13256
--       directly, to confirm the single-order finding from
--       query 30 by seeing the actual row(s), not just an
--       aggregate count.
-- WHY: Query 30 showed 13256 has exactly 1 order compared to
--      substantial histories for neighboring customer_ids.
--      Confirming this directly, by looking at the row itself,
--      rather than relying solely on the aggregate count.
--
-- NOTE: The first version below (no decimal) was run first and
-- returned 0 rows — not an error, but no match found. This was
-- unexpected. Re-checking the raw data revealed customer_id is
-- stored with a trailing ".0" (e.g. "13256.0"), a float-
-- formatting artifact from import. The second version below,
-- with the decimal included, returned the expected row. Both
-- versions are kept here intentionally: the failed first
-- attempt is what surfaced the trailing-decimal finding that
-- led to query 32.
-- ============================================================

-- Attempt 1 — returned 0 rows
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE customer_id = '13256'
ORDER BY invoice_date;

-- Attempt 2 — returned the expected row
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE customer_id = '13256.0'
ORDER BY invoice_date;