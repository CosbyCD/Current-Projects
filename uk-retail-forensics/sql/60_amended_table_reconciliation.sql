-- Query 60_amended_table_reconciliation

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

-- RESULT: 0 -- confirmed no rows in the amended clean_transactions
-- match the non-numeric stock code pattern, matching the log exactly.

-- CONFIRMED FINDING: PASSED, on its own terms -- the administrative-
-- code exclusion from Query 59 is verified complete: zero rows remain
-- that match the exclusion pattern. However, this verification cannot
-- distinguish between two different outcomes that would both produce
-- the same result: (1) all genuine administrative codes correctly
-- removed, or (2) the same, PLUS the "47503J " false-positive row
-- flagged in Query 59's writeup also correctly (from this check's
-- narrow perspective) showing zero, since that row was excluded by
-- the identical regex and would never appear in this count either way.
-- A result of 0 here is fully consistent with both the correct
-- outcome and the flawed one -- this check verifies the exclusion
-- pattern was applied exhaustively, not that everything it excluded
-- deserved to be excluded. The Query 59 finding (one legitimate
-- product row lost to a known formatting defect) stands unaddressed
-- by this verification and remains an open, uncorrected issue at this
-- point in the project.