-- Query 10_stock_code_breakdown_negative_blank

-- ============================================================
-- SUPPORTING CHECK: Stock code concentration in the 2,689
-- WHAT: Breaks down the 2,689 negative-qty/blank-description
--       rows by stock_code, to see if the pattern concentrates
--       on specific products or spreads across many.
-- WHY: Query 06 found this pattern on 15044B. Checking whether
--      that was a one-off product or whether this undocumented
--      category shows up broadly across many different stock
--      codes — useful context for the data quality write-up.
-- ============================================================
SELECT stock_code, COUNT(*) AS occurrences
FROM uk_retail.raw_transactions
WHERE quantity < 0
AND (description IS NULL OR TRIM(description) = '')
GROUP BY stock_code
ORDER BY occurrences DESC
LIMIT 20;

-- RESULT: Even the MOST-affected stock codes in the entire 2,689-row
-- population top out at only 4 occurrences each (14 stock codes tied at
-- 4, including 84559D, 20892, 22162, 37476, 20966, 21161, 21763, 22034,
-- 37464, 21040, 85017A, 85126, 22028, 21768), dropping to 3 occurrences
-- for the next tier. No single stock code accounts for anything close to
-- a meaningful share of the 2,689 total — the maximum any one code
-- contributes is roughly 0.15% of the full pattern.

-- CONFIRMED FINDING: The negative-qty/blank-description pattern is
-- confirmed to be broadly distributed across the product catalog, not
-- concentrated on a handful of problem products. 15044B (Query 06's
-- original example) was not a special case — it's one of thousands of
-- individual stock codes each contributing a handful of occurrences to
-- the total. Combined with Queries 08-09 (no cancellation flag, no
-- customer_id), this rules out a product-specific explanation (e.g. one
-- faulty SKU or one troublesome product line) and reinforces that this
-- is a systemic data-entry/inventory-adjustment pattern that touches the
-- catalog broadly rather than a localized issue confined to a few items.
-- No further stock-code-specific investigation is warranted for this
-- category — the exclusion logic (Query 24) can treat it as a uniform
-- rule applied dataset-wide, not something requiring per-product
-- exceptions.