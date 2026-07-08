 ============================================================
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