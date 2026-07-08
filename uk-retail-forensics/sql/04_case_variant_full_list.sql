-- ============================================================
-- FINDING: Stock code casing inconsistency — full scope
-- WHAT: Finds every numeric+letter stock code that has more
--       than one casing variant somewhere in the raw table
--       (e.g. 15056BL and 15056bl both existing).
-- WHY: Query 03 confirmed one example (15056BL/15056bl) was
--      the same product entered with inconsistent casing.
--      This finds the full extent of the issue across the
--      entire dataset, not just the one example spotted by
--      eye, before deciding whether to normalize casing
--      project-wide.
-- ============================================================
SELECT
    UPPER(stock_code) AS normalized_code,
    ARRAY_AGG(DISTINCT stock_code) AS case_variants,
    COUNT(DISTINCT stock_code) AS variant_count
FROM uk_retail.raw_transactions
WHERE stock_code ~ '^[0-9]+[A-Za-z]+$'
GROUP BY UPPER(stock_code)
HAVING COUNT(DISTINCT stock_code) > 1
ORDER BY normalized_code;