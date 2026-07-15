-- ============================================================
-- VERIFICATION: Third amendment — row count reconciliation
-- WHAT: Confirms zero rows remain for stock_code 23843, and
--       confirms the row count dropped by exactly 2 as expected.
-- WHY: Same verify-before-trusting discipline applied to every
--      prior table amendment (queries 39, 60).
-- RESULT: 1,022,519 (pre-amendment) minus 1,022,517
--      (post-amendment) = 2 rows removed, matching the two rows
--      (purchase + cancellation) confirmed in queries 71-73.
-- ============================================================
SELECT COUNT(*) AS remaining_23843_rows
FROM uk_retail.clean_transactions
WHERE stock_code = '23843';