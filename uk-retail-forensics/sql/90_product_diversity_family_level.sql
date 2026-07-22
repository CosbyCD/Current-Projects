-- Query 90_product_diversity_family_level

-- ============================================================
-- CHAPTER TWO, FIELD 5: Product Diversity — family level
-- WHAT: Counts distinct product families purchased per
--       customer, using completed orders only. A family is the
--       base stock code with trailing letters stripped (e.g.
--       15056BL and 15056PK both roll up to family 15056),
--       consistent with the two-tier structure identified in
--       Phase 2 (query 05).
-- WHY: Second of two diversity measures. This rolls up
--       variants of the same base item (different colorways,
--       versions) into one family count, answering "how many
--       distinct kinds of product" rather than "how many exact
--       product codes."
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT REGEXP_REPLACE(stock_code, '[A-Za-z]+$', '')) AS distinct_families_purchased
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY distinct_families_purchased DESC;

-- RESULT: Top customer 14911 at 2,348 distinct families -- down from
-- 2,546 distinct variants at Query 89, a reduction of 198. This
-- confirms the family rollup is doing real collapsing work, not
-- returning an identical count under a different label. 5,852 rows,
-- matching Query 89's completed-only population exactly -- same
-- customers, same filter, only the grouping granularity differs.

-- CONFIRMED FINDING: Product diversity at the family level is built
-- correctly and produces a genuinely different, smaller count than
-- the variant-level version for the same customer -- confirming the
-- two measures capture meaningfully different things, consistent with
-- this project's standard practice of building both sides of a
-- methodological fork rather than assuming one subsumes the other.
-- The 198-code gap for customer 14911 alone suggests casing and
-- trailing-letter variants (the same pattern investigated in Chapter
-- One, Queries 02-05) account for real, non-trivial inflation in the
-- variant-level count. Both diversity measures are now built and
-- ready to be carried forward together into the final customer_
-- behavior_fields table, the same way frequency and monetary value
-- each kept two components rather than collapsing to one number.