-- Query 44_clean_transactions_country_spotcheck

-- ============================================================
-- VERIFICATION: clean_transactions — country normalization spot-check
-- WHAT: Confirms no row in clean_transactions retains the raw
--       "Unspecified" or "European Community" country values —
--       both should have been merged into the single tracked
--       "Unspecified-European Community" category.
-- WHY: Part of the verification/audit pass. Confirms the
--      country field normalization rule from Thread 5 was
--      actually applied correctly at the row level.
-- ============================================================
SELECT DISTINCT country FROM uk_retail.clean_transactions
WHERE country IN ('Unspecified', 'European Community', 'Unspecified-European Community');

-- RESULT: Only "Unspecified-European Community" appears in the result
-- set -- confirmed pass. Neither the raw "Unspecified" nor "European
-- Community" value survived independently anywhere in clean_transactions.

-- CONFIRMED FINDING: PASSED. The country normalization rule from
-- Thread 5 (Query 34, merging "Unspecified" and