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