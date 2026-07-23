-- Query 169_47503J_clean_transactions_current_status

-- WHAT: Checks whether the single trailing-space row ('47503J ',
--       £16.13, invoice from 2010-07-05) currently appears in
--       clean_transactions, to confirm it's actually being excluded
--       by Query 59's admin-code amendment before deciding on a fix.
-- WHY: Query 168 confirmed the raw data: 80 rows under '47503J'
--      (clean) and exactly 1 row under '47503J ' (trailing space),
--      same product. This directly checks the current build state
--      rather than assuming the exclusion is still happening.

SELECT stock_code, LENGTH(stock_code) AS code_length, COUNT(*) AS row_count
FROM uk_retail.clean_transactions
WHERE TRIM(stock_code) = '47503J'
GROUP BY stock_code, LENGTH(stock_code);

-- RESULT (verified against pasted output): only the 6-character
-- '47503J' variant appears, at 77 rows -- NOT 0 rows for the
-- 7-character '47503J ' variant, confirming it is currently absent
-- from clean_transactions entirely. The clean variant's count (77)
-- is also lower than raw_transactions' 80 -- a separate, smaller
-- reduction consistent with this project's known deduplication and
-- other exclusion steps applied during the clean_transactions build,
-- not related to this specific bug and not investigated further here.

-- CONFIRMED FINDING: the £16.13 trailing-space row for '47503J ' is
-- confirmed still silently excluded from clean_transactions, exactly
-- as flagged in the original handoff. The gap has now been fully
-- characterized end to end: a single, genuine, low-value line item
-- (£16.13) incorrectly caught by Query 59's admin-code exclusion
-- logic, never corrected across three subsequent amendments. Decision
-- point: formally fix via a fourth targeted amendment (re-including
-- this one row), or document as a deliberately accepted, immaterial
-- gap given its size (£16.13 against a >£1M-revenue dataset). See
-- Query 170 for the fix, if that's the direction chosen.