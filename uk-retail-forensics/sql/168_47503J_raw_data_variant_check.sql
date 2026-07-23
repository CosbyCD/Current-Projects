-- Query 168_47503J_raw_data_variant_check

-- WHAT: Pulls all raw_transactions rows for stock_code '47503J' (with
--       and without trailing whitespace, checked separately by
--       grouping on the exact stock_code value and its LENGTH) to
--       characterize the two variants directly rather than assuming
--       Query 20's original finding still holds without re-checking.
-- WHY: Query 166's attempt failed before running (truncated WHERE
--      clause). Query 167 confirmed raw_transactions has the expected
--      stock_code column. This is the corrected, complete version --
--      grouping separately by code_length distinguishes the clean
--      6-character code from the 7-character trailing-space variant,
--      rather than collapsing them together under a single TRIM'd
--      value.

SELECT
    stock_code,
    LENGTH(stock_code) AS code_length,
    description,
    COUNT(*) AS row_count,
    SUM(quantity * unit_price) AS total_value,
    MIN(invoice_date) AS earliest,
    MAX(invoice_date) AS latest
FROM uk_retail.raw_transactions
WHERE TRIM(stock_code) = '47503J'
GROUP BY stock_code, LENGTH(stock_code), description
ORDER BY code_length;

-- RESULT (verified against pasted output): two distinct variants, same
-- product ("SET/3 FLORAL GARDEN TOOLS IN BAG"). '47503J' (6 characters,
-- no trailing space): 80 rows, £2,592.18, spanning 2009-12-01 to
-- 2010-12-07. '47503J ' (7 characters, trailing space): exactly 1 row,
-- £16.13, single invoice dated 2010-07-05 10:07:00. This confirms
-- Query 20's original finding precisely -- a genuine product entered
-- with a stray trailing space on one invoice, not an administrative
-- code requiring exclusion.

-- CONFIRMED FINDING: the scope of this gap is small and fully
-- characterized -- a single £16.13 line item. Whether it currently
-- survives into clean_transactions (i.e. whether Query 59's
-- admin-code amendment is still silently excluding it) is checked
-- next at Query 169.