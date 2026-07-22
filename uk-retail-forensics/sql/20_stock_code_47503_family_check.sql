-- Query 20_stock_code_47503_family_check

-- ============================================================
-- FINDING: 47503 family — trailing space false positive, and
--          placeholder text in description ("check", "found")
-- WHAT: Pulls every variant of the 47503 stock code family to
--       verify whether "47503J " (with trailing space) found
--       in query 19 is a genuine administrative code or a data
--       entry error on an existing product.
-- WHY: Query 19's non-numeric stock code regex caught
--      "47503J " due to a trailing space, inflating the true
--      count. Confirmed: 47503J already exists as a normal
--      product ("SET/3 FLORAL GARDEN TOOLS IN BAG", 80
--      occurrences) — the spaced version is the same product
--      with a stray whitespace character, not a real
--      administrative code. Also surfaced a new finding: two
--      rows on 47503H have literal placeholder text ("check",
--      "found") in the description field instead of a real
--      product description — a pattern not yet characterized.
-- ============================================================
SELECT stock_code, description, COUNT(*)
FROM uk_retail.raw_transactions
WHERE stock_code LIKE '47503%'
GROUP BY stock_code, description;

-- RESULT: Confirms both parts of the hypothesis. First: "47503J " (1
-- occurrence, trailing space) and "47503J" (80 occurrences, no trailing
-- space) share the identical description "SET/3 FLORAL GARDEN TOOLS IN
-- BAG" -- definitively the same product, split into two distinct
-- stock_code values purely by a whitespace formatting defect. This
-- confirms the Query 19 false-positive flag: "47503J " should not count
-- toward the administrative-code total, and the true dataset-wide
-- non-numeric code count is 6,092, not 6,093, once this one row is
-- reclassified. Second, and new: across the 47503 family, description
-- is not just blank in some rows (47503A, E, F, G, K all show blank-
-- description rows alongside their populated-description rows, echoing
-- the pattern from Queries 15-16) -- two rows on 47503H contain literal
-- English words as the description: "check" (1 occurrence) and "found"
-- (1 occurrence), rather than either a real product name or a blank
-- field. These read as operator annotations left in the description
-- field itself, distinct from both the blank-description pattern and
-- the genuine product-description rows.

-- CONFIRMED FINDING: Two separate, previously uncharacterized data
-- issues confirmed on this one product family. (1) Trailing/leading
-- whitespace on stock_code values can silently fracture a single real
-- product into multiple distinct code strings -- this is a stock_code
-- normalization issue (TRIM() needed) separate from the casing issue
-- already handled in Queries 02-05, and the full dataset should be
-- checked for other whitespace-split codes before stock-code-based
-- product counts are trusted (candidate for a dedicated follow-up
-- query). (2) Operator annotation text ("check", "found", and likely
-- other short English-word entries) appearing directly in the
-- description field is a distinct pattern from blank description --
-- this was already glimpsed informally in Query 05's family-rollup
-- result (which listed "check", "damaged", "missing", "found", "wrong
-- invc" as recurring non-product description values) but never
-- formally quantified across the dataset. Both issues are narrow in
-- scope on this one family (3 total rows) but establish patterns that
-- likely recur elsewhere in the ~5,875-product catalog and should be
-- checked at full scale before the clean_transactions description field
-- is trusted for any product-name-based analysis.