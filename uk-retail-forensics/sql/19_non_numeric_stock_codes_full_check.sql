-- Query 19_non_numeric_stock_codes_full_check

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

-- RESULT: 6,093 total rows across 62 distinct non-numeric stock codes —
-- confirmed by summing all returned occurrence counts. Dominated by a
-- small number of high-frequency codes: POST (2,122, postage charges),
-- DOT (1,446), M (1,421, manual entries), C2 (282), D (177), S (104),
-- BANK CHARGES (102), ADJUST (67), AMAZONFEE (43). The long tail is
-- overwhelmingly DCGS-prefixed codes (gift card / discount-style
-- administrative codes, ~35 distinct variants, most appearing only
-- 1-15 times each) and gift_0001_NN denomination codes (9 variants,
-- 2-29 occurrences each) already seen in Query 15's zero-price
-- population. One entry, "47503J " (with a trailing space), is a
-- genuine product code caught by the regex only because of a
-- whitespace formatting defect -- not a true administrative code; this
-- is a false positive in this result and should be excluded from the
-- administrative-code category, though the trailing-space issue itself
-- is worth flagging for the stock_code cleaning pass.

-- CONFIRMED FINDING: The true dataset-wide count of non-numeric/
-- administrative stock code rows is 6,093 -- more than triple the 1,795
-- figure reported by an independently published analysis of this same
-- dataset, and roughly 165x the 37-row count found in Query 16's
-- narrower blank-description-only subset. The discrepancy with the
-- external 1,795 figure is not yet explained and should not be assumed
-- to indicate an error on either side -- the other analysis may have
-- used a different code-pattern definition, applied additional filters
-- (e.g. excluding cancellations, or a different set of admin codes
-- treated as "known"), or worked from a differently-cleaned version of
-- the source file. This is noted as an open discrepancy, not resolved,
-- and should not be cited as either confirming or contradicting the
-- external source without further investigation. What IS confirmed
-- independently: administrative/non-product codes are a real, non-trivial
-- population (6,093 rows, ~0.57% of the full dataset) requiring
-- exclusion before customer-behavior-field construction, consistent
-- with -- and now numerically superseding -- the partial count found in
-- Query 16.