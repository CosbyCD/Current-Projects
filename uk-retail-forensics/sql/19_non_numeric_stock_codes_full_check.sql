-- ============================================================
-- INVESTIGATION: Non-numeric / administrative stock codes —
--                full dataset-wide check
-- WHAT: Finds every row across the entire dataset where
--       stock_code does not follow the standard numeric (or
--       numeric+letter) product code pattern — codes like
--       POST, DOT, C2, BANK CHARGES, MANUAL, TEST001/002,
--       gift_0001_XX, AMAZONFEE, DCGS-prefixed codes.
-- WHY: An earlier check (query 16) found only 37 such rows,
--      but that check was scoped narrowly to the 1,693 blank-
--      description subset, not the full dataset. A separate
--      independently published analysis of this same dataset
--      found 1,795 rows needing removal for this reason,
--      dataset-wide. This runs the equivalent full-dataset
--      check to get a true, comparable count and see the
--      actual scope of non-product administrative entries.
-- ============================================================
SELECT stock_code, COUNT(*) AS occurrences
FROM uk_retail.raw_transactions
WHERE stock_code !~ '^[0-9]+[A-Za-z]*$'
GROUP BY stock_code
ORDER BY occurrences DESC;