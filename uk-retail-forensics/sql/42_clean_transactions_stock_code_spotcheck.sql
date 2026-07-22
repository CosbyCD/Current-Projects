-- Query 42_clean_transactions_stock_code_spotcheck

-- ============================================================
-- VERIFICATION: clean_transactions — stock code casing spot-check
-- WHAT: Confirms every row for the 15056BL/bl family in
--       clean_transactions shows only the normalized uppercase
--       form, with no lowercase or mixed-case variants remaining.
-- WHY: Part of the verification/audit pass before Chapter One is
--      considered closed. Row-count reconciliation (query 39)
--      confirmed the table's size is correct, but does not by
--      itself prove every transformation actually landed as
--      intended — this checks the stock code casing rule
--      directly at the row level.
-- ============================================================
SELECT stock_code FROM uk_retail.clean_transactions
WHERE stock_code IN ('15056BL', '15056bl', '15056Bl');

-- RESULT: Only "15056BL" (the normalized uppercase form) appears in
-- the result set -- no rows returned for "15056bl" or "15056Bl".
-- Confirmed clean: the casing normalization applied in Query 38's
-- `UPPER(stock_code)` transformation landed correctly for this test
-- case, with zero lowercase or mixed-case variants remaining in
-- clean_transactions.

-- CONFIRMED FINDING: PASSED. The stock code casing rule, first
-- identified in Query 02 and confirmed as a genuine data-entry
-- inconsistency in Query 03 (15056BL/15056bl -- same product,
-- "EDWARDIAN PARASOL BLACK," inconsistent casing), is verified at the
-- row level in the finished clean_transactions table, not just assumed
-- correct from the transformation logic alone. This is one of several
-- direct row-level spot-checks run as part of the Chapter One
-- verification/audit pass (alongside the file integrity, numbering
-- integrity, and row-count reconciliation checks), confirming
-- clean_transactions is sound at both the aggregate and row level
-- before Chapter Two begins.