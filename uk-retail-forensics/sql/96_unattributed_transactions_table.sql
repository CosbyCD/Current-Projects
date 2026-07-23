-- Query 96_unattributed_transactions

-- ============================================================
-- RESOLUTION: The no-customer-ID open question from query 35
-- WHAT: Builds uk_retail.unattributed_transactions as a copy of
--       every row in clean_transactions where customer_id IS
--       NULL (243,007 rows). clean_transactions itself is left
--       completely unchanged — this is a copy for reference and
--       future examination, not a removal.
-- WHY: Query 35's review (item 4) flagged this as an open
--      decision that was never formally resolved in writing,
--      even though every customer-level field query has
--      functionally excluded these rows all along via
--      WHERE customer_id IS NOT NULL. These rows are not
--      errors — unlike excluded_rows, nothing here has been
--      identified as a data entry mistake. They are legitimate
--      transactions missing a customer identifier (a common
--      real-world pattern: guest checkouts, anonymous sales).
--      Consistent with this project's standing rule — never
--      delete, always segregate and preserve — they are copied
--      into their own dedicated table for future examination
--      rather than silently filtered out with no record.
-- ============================================================
DROP TABLE IF EXISTS uk_retail.unattributed_transactions;
CREATE TABLE uk_retail.unattributed_transactions AS
SELECT * FROM uk_retail.clean_transactions
WHERE customer_id IS NULL;

-- RESULT: Table created successfully. Actual row count via
-- SELECT COUNT(*) FROM uk_retail.unattributed_transactions
-- returned 228,297 rows — NOT 243,007 as stated in the WHAT
-- block above. Discrepancy of 14,710 rows, direction and cause
-- not yet determined (could be a stale figure from an earlier
-- draft/estimate, a change in clean_transactions between when
-- that figure was written and when this query actually ran, or
-- a miscount at the time the WHAT block was drafted).

-- CONFIRMED FINDING: uk_retail.unattributed_transactions is built
-- and holds 228,297 rows (verified via direct COUNT, not the
-- 243,007 figure in this file's own WHAT block, which is flagged
-- here as unverified/incorrect pending investigation). This
-- resolves the open Query 35 item 4 question in principle — these
-- rows are now preserved in a dedicated table rather than silently
-- excluded — but the row-count discrepancy is an open item that
-- should be run down before this number is cited anywhere else
-- (e.g. Chapter Four documentation, the exhibit gallery, or any
-- MRP/inventory sprint work that plans to fold this table back in).

-- [REVISION NOTICE — added per Query 97_unattributed_transactions_reconciliation,
-- run July 21, 2026: The 243,007 vs. 228,297 discrepancy flagged in this
-- query's own RESULT block above is resolved. Query 97 independently
-- re-confirmed 228,297 via a direct COUNT(*) against clean_transactions,
-- matching this query's CREATE TABLE AS result exactly. The gap traces to
-- timing — 243,007 was established at Query 14 against raw_transactions,
-- before deduplication and before three subsequent clean_transactions
-- amendments; those rows were excluded from clean_transactions for other,
-- already-documented cleaning reasons before ever reaching this
-- segregation step. 228,297 is confirmed final.]