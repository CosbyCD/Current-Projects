-- Query 09_negative_qty_blank_desc_vs_customerid

-- ============================================================
-- FINDING: Cross-check against missing CustomerID group
-- WHAT: Of the 2,689 negative-quantity/blank-description rows,
--       how many have a customer_id vs. how many don't.
-- WHY: Query 06 showed the anomalous row (556012) had no
--      customer_id at all, unlike the genuine cancellation
--      next to it. Testing whether that holds across the full
--      2,689-row pattern — i.e., whether this undocumented
--      category overlaps with the original no-CustomerID
--      finding (243,007 rows, 22.8% of dataset).
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS no_customer,
    COUNT(*) FILTER (WHERE customer_id IS NOT NULL AND TRIM(customer_id) != '') AS has_customer
FROM uk_retail.raw_transactions
WHERE quantity < 0
AND (description IS NULL OR TRIM(description) = '');

-- RESULT: total = 2,689; no_customer = 2,689; has_customer = 0. Complete
-- overlap — every single one of the 2,689 negative-quantity/blank-
-- description rows also has no customer_id.

-- CONFIRMED FINDING: The 2,689-row anomalous category is fully nested
-- inside the broader no-CustomerID group (243,007 rows total) — every
-- one of these 2,689 rows lacks a customer_id, consistent with Query 06's
-- single-example observation now confirmed at full scale. Combined with
-- Query 08's finding (zero overlap with "C"-prefix cancellations), this
-- category is now triply confirmed distinct from genuine customer
-- activity: no cancellation marker, no customer attached, and no
-- description. This is strong, consistent evidence that these 2,689 rows
-- represent internal stock/inventory adjustments entered through the
-- transaction table rather than any form of customer-facing sale or
-- return — reinforcing that they must be excluded (not reinterpreted)
-- before customer-behavior fields are built. Also worth noting: these
-- 2,689 rows are a small fraction (about 1.1%) of the larger 243,007-row
-- no-CustomerID population — meaning the no-CustomerID group as a whole
-- is not just "adjustment" rows; the vast majority of no-CustomerID rows
-- must be something else (e.g. guest/unattributed purchases) and warrant
-- their own separate characterization, not lumped in with this specific
-- negative-qty-blank-desc pattern. See Query 10 for the broader
-- stock-code breakdown of this category.