-- Query 21_placeholder_text_in_description_check

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

-- RESULT: 327 total rows match this specific word list, confirming the
-- pattern from Query 20 is dataset-wide, not isolated to 47503H.
-- "check" dominates at 162 occurrences (plus 3 more as "CHECK" — 165
-- total across casings), followed by "?" at 92, "found"/"Found"/"FOUND"
-- at 38 combined, and "missing"/"Missing"/"MISSING" at 30 combined.
-- Casing is inconsistent across all terms, echoing the same
-- inconsistency pattern already documented for stock codes in Queries
-- 02-05. This query only checked a fixed, hand-picked list of terms —
-- it does NOT capture other operator-note-style values already glimpsed
-- informally in Query 05's family rollup ("damaged", "wrong invc",
-- "dotcom sales", "entry error", "thrown away", "adjustment"), so 327 is
-- a floor on the true scope of this pattern, not an exhaustive count.

-- CONFIRMED FINDING: Placeholder/operator-note text in the description
-- field is a confirmed, dataset-wide pattern (at least 327 rows across
-- the specific terms checked here), not an isolated artifact of one
-- product family. Combined with the casing inconsistency also present
-- in these terms, this reinforces that description cannot be trusted as
-- a clean product-name field without further cleaning -- consistent
-- with the blank-description findings in Queries 14-16 but representing
-- a distinct sub-pattern (populated-but-non-product text, rather than
-- empty text). Given this query's word list was hand-picked rather than
-- derived systematically, a follow-up scan for short, low-frequency,
-- non-product-looking description values (e.g. by filtering to
-- descriptions under a certain character length, or descriptions that
-- appear on stock codes that already have a separate "real" description
-- elsewhere, as 47503H does) would give a more complete picture. Not
-- pursued further within this project's current scope, per the
-- 20-day sprint's prioritization -- flagged here as a candidate for the
-- "Additional Avenues" documentation section rather than chased down
-- exhaustively now.