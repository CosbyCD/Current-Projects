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