-- Query 34_country_normalize_unspecified

-- ============================================================
-- FINDING: Country field — "Unspecified" and "European Community"
--          combined into a single tracked non-specific category
-- WHAT: Combines "Unspecified" (756 rows) and "European
--       Community" (61 rows) into a single labeled category —
--       "Unspecified-European Community" — rather than treating
--       them as two separate values or discarding the
--       distinction entirely.
-- WHY: Both values represent geographically non-specific data,
--      but they're not identical in meaning: "Unspecified" is
--      a true placeholder with no information, while "European
--      Community" is an imprecise but not meaningless signal
--      (somewhere in the EU). Combining them into one clearly-
--      labeled category preserves the fact that both are
--      non-specific, while keeping this group distinct from
--      genuine country data. Kept as its own tracked category
--      (not excluded) since the volume of non-specific entries,
--      compared against genuine country data, may itself be a
--      useful signal in the eventual nodal visualization —
--      a possible indicator of data entry gaps or process
--      issues concentrated in certain time periods or channels.
-- ============================================================
SELECT
    CASE
        WHEN country IN ('Unspecified', 'European Community')
            THEN 'Unspecified-European Community'
        ELSE country
    END AS country_normalized,
    COUNT(*) AS occurrences
FROM uk_retail.raw_transactions
GROUP BY country_normalized
ORDER BY occurrences DESC;

-- RESULT: 39 distinct country_normalized values (down from 41),
-- confirming the merge worked as intended. "Unspecified-European
-- Community" shows exactly 817 occurrences -- an exact match to
-- 756 + 61 = 817 from Query 33, confirming no rows were lost, double-
-- counted, or miscategorized during the merge. All other country
-- values pass through unchanged, in the same rank order as Query 33.
-- "RSA" (169 rows) was deliberately left untouched, consistent with
-- Query 33's finding that it's a legitimate abbreviation rather than a
-- placeholder needing this kind of merge.

-- CONFIRMED FINDING: The normalization is confirmed exact and lossless
-- -- "Unspecified" and "European Community" are now tracked as a single
-- combined category (817 rows, ~0.08% of the dataset) rather than two
-- separate ambiguous-country entries, while every genuine country value
-- remains untouched. This preserves the useful signal that both values
-- represent non-specific geography, without conflating them with real
-- country data or silently discarding the distinction. "RSA" remains a
-- separate, standalone value pending a possible future normalization to
-- "South Africa" -- not addressed in this pass, since it's a legitimate
-- abbreviation rather than a placeholder. This closes the country-field
-- investigation thread (33-34): the field is now fully characterized,
-- with a clear, documented, and reversible normalization applied to its
-- one genuine placeholder pattern.