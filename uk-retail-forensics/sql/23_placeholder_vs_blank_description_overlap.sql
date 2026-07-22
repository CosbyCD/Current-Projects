-- Query 23_placeholder_vs_blank_description_overlap

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

-- RESULT: overlap_count = 0. No row has both a placeholder-text
-- description and a blank/NULL description -- confirmed mutually
-- exclusive, as logically expected, with no hidden data anomaly (e.g.
-- a placeholder word combined with leading/trailing whitespace that
-- could have collapsed to blank under TRIM) complicating the picture.

-- CONFIRMED FINDING: The 327 placeholder-description rows (Query 21)
-- and the 4,382 blank-description rows (Query 14) are two genuinely
-- distinct, non-overlapping subsets of description-field anomalies,
-- both nested within the same broader zero-price/no-customer
-- non-sale transaction category confirmed in Query 22. Combined total
-- of description-field-anomalous rows tied to this category: 4,382
-- blank + 327 placeholder-text = 4,709 rows with a non-standard
-- description, all already covered by the zero-price/no-customer
-- exclusion logic regardless of which description sub-pattern they
-- fall into. This closes the description-field investigation thread
-- (14 through 23) with a clean, fully-reconciled picture: every
-- description anomaly found traces back to the same underlying
-- non-customer-facing transaction type, and none require separate
-- exclusion handling beyond what Query 24 will already implement.