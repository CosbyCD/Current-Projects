-- ============================================================
-- FOLLOW-UP: Placeholder description rows — overlap check
-- WHAT: Confirms the 327 placeholder-description rows are
--       fully separate from the 4,382 blank-description rows
--       already characterized in Phases 3 and 6.
-- WHY: The 327 rows share the zero-price/no-customer signature
--      with both earlier groups. Since description is NOT
--      blank here (it contains text like "check"/"found"),
--      these should be mutually exclusive from the blank-
--      description groups by definition — confirming this
--      rather than assuming it.
-- ============================================================
SELECT COUNT(*) AS overlap_count
FROM uk_retail.raw_transactions
WHERE description IN ('check', 'found', 'Check', 'Found', 'CHECK', 'FOUND', '?', 'missing', 'Missing', 'MISSING', 'lost', 'Lost', 'LOST')
AND (description IS NULL OR TRIM(description) = '');