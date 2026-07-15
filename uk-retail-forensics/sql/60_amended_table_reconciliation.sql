-- ============================================================
-- VERIFICATION: Amended clean_transactions — row count check
-- WHAT: Confirms the administrative-code exclusion actually
--       removed rows in the expected range, and separately
--       confirms zero administrative codes remain.
-- WHY: Same verify-before-trusting discipline applied to the
--      original table build (query 39). 1,028,437 (pre-amend)
--      minus 1,022,519 (post-amend) = 5,918 rows removed.
-- ============================================================
SELECT COUNT(*) AS remaining_admin_code_rows
FROM uk_retail.clean_transactions
WHERE stock_code !~ '^[0-9]+[A-Za-z]*$';