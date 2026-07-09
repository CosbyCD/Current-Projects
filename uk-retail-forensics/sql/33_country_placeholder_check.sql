-- ============================================================
-- INVESTIGATION: Country field — placeholder/non-country values
-- WHAT: Checks the country column for values that aren't real
--       country names — blanks, "Unspecified," or similar
--       placeholder entries — across the full dataset.
-- WHY: Thread 5, the last open item from the Phase 5 completeness
--      audit. The audit itself found 0 true blanks/nulls in
--      country, but a populated field can still contain a
--      placeholder value rather than a real country, the same
--      way description contained "check"/"found" instead of a
--      real product name (Thread 3).
-- ============================================================
SELECT country, COUNT(*) AS occurrences
FROM uk_retail.raw_transactions
GROUP BY country
ORDER BY occurrences DESC;