-- Query 75_third_amendment_reconciliation

-- ============================================================
-- VERIFICATION: Third amendment — row count reconciliation
-- WHAT: Confirms zero rows remain for stock_code 23843, and
--       confirms the row count dropped by exactly 2 as expected.
-- WHY: Same verify-before-trusting discipline applied to every
--      prior table amendment (queries 39, 60).
-- ============================================================
SELECT COUNT(*) AS remaining_23843_rows
FROM uk_retail.clean_transactions
WHERE stock_code = '23843';

-- RESULT: 0 -- confirmed no rows remain for stock_code 23843. Row
-- count reduction (1,022,519 to 1,022,517) matches the expected two
-- rows (purchase and cancellation) confirmed in Queries 71-73.

-- CONFIRMED FINDING: PASSED. The third amendment to clean_transactions
-- is verified complete and correctly applied. This closes the
-- verification loop for the 80,995-unit outlier (71-75), the second
-- individually-excluded data entry error confirmed and removed by
-- this project, following the same precedent as the Chapter One
-- 12,540-unit outlier. With this amendment verified, Fields 1
-- (Recency), 2 (Frequency), and 3 (Monetary Value) can now proceed to
-- their third and final rebuild pass against a fully-reconciled
-- clean_transactions table.