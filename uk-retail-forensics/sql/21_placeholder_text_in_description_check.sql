-- ============================================================
-- INVESTIGATION: Placeholder/note-like text in description field
-- WHAT: Checks whether short, note-like words ("check", "found",
--       and similar placeholder text) appear elsewhere in the
--       description field dataset-wide, beyond the two instances
--       spotted on stock_code 47503H in query 20.
-- WHY: Query 20 surfaced two rows where description contained
--      "check" and "found" instead of a real product description
--      — looks like an internal note left behind during a manual
--      correction rather than actual product text. Checking how
--      widespread this pattern is before deciding how to handle
--      it in the clean table.
-- ============================================================
SELECT description, COUNT(*) AS occurrences
FROM uk_retail.raw_transactions
WHERE description IN ('check', 'found', 'Check', 'Found', 'CHECK', 'FOUND', '?', 'missing', 'Missing', 'MISSING', 'lost', 'Lost', 'LOST')
GROUP BY description
ORDER BY occurrences DESC;
