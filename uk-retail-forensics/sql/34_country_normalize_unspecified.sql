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