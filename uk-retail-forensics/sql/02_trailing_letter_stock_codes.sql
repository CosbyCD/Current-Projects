-- Query 02_trailing_letter_stock_codes

-- ============================================================
-- FINDING: Stock codes with trailing letters
-- WHAT: Pulls every distinct stock code that is a number
--       followed by one or more letters (e.g. 85123A),
--       sorted by numeric part ascending, then trailing
--       letter ascending within each number.
-- WHY: Noticed while scrolling that some stock codes have
--      trailing letters — investigating whether these are
--      product variants (color/style) before deciding how
--      to treat them in product diversity calculations.
--      Ascending letter order within each family makes it
--      easy to see how many variants exist per product and
--      to spot casing duplicates (e.g. 15056BL vs 15056bl)
--      sitting near each other in the list.
-- ============================================================
SELECT DISTINCT
    stock_code,
    CAST(SUBSTRING(stock_code FROM '^[0-9]+') AS INTEGER) AS numeric_part,
    SUBSTRING(stock_code FROM '[A-Za-z]+$') AS trailing_letter
FROM uk_retail.raw_transactions
WHERE stock_code ~ '^[0-9]+[A-Za-z]+$'
ORDER BY
    numeric_part ASC,
    trailing_letter ASC;

-- RESULT: Several hundred distinct trailing-letter stock codes returned,
-- spanning numeric families from 10002 through 90214. The vast majority
-- are genuine single- or multi-letter product variants (e.g. 85123A,
-- 85123B — color/style variants of one base product). A follow-up count
-- (Query 03) confirmed exactly 165 stock codes exist as exact casing
-- duplicates of another code (same numeric part + same letter, differing
-- only by upper/lower case) — e.g. 15056bl / 15056BL. This is a genuine
-- source-data casing inconsistency affecting real product variant codes,
-- not noise.

-- CONFIRMED FINDING: Trailing letters on stock codes are genuine product
-- variant codes (not noise), but variant casing is inconsistent at the
-- source-data level across a large number of product families. This
-- casing inconsistency needs to be resolved (normalized to one case)
-- before trailing-letter codes can be used reliably in any product
-- diversity or variant-count calculation — otherwise the same physical
-- variant would be double-counted as two distinct codes differing only
-- by case. See Query 03 for the exact case-duplicate count (165 pairs
-- confirmed) and Queries 04-05 for the full variant list and family-level
-- rollup logic built to resolve it.