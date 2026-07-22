-- Query 04_case_variant_full_list

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

-- RESULT: 165 distinct normalized stock codes exist as exact-casing
-- duplicate pairs — in every case, exactly 2 casings (no 3+ way case
-- collisions found anywhere in the result set). Spans a wide range of
-- product families, with some families showing multiple affected
-- letters within the same base number (e.g. 84509 affected at A, B, C,
-- E, and G; 85049 affected at A, B, C, D, E, and G). No pattern by
-- numeric range — affected codes appear from the 15000s through the
-- 90000s, meaning this is a systemic data-entry issue, not confined to
-- one batch, one time period, or one product line.

-- CONFIRMED FINDING: 165 stock codes are confirmed exact-casing
-- duplicates of another code already present in the dataset — the same
-- physical product variant recorded under two different capitalizations
-- of the same code, occurring throughout the full range of the dataset
-- rather than in one isolated batch. This must be normalized (collapsed
-- to a single consistent casing per code) before any product-diversity
-- or variant-count calculation, or these 165 pairs would each be
-- double-counted as two separate products rather than one. See Query 05
-- for the family-level rollup logic built to resolve this.