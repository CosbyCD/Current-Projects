-- Query 89_product_diversity_variant_level

-- ============================================================
-- CHAPTER TWO, FIELD 5: Product Diversity — variant level
-- WHAT: Counts distinct stock codes (exact variant, e.g.
--       15056BL specifically) purchased per customer, using
--       completed orders only.
-- WHY: Fifth of the six derived customer behavior fields.
--      First of two diversity measures, following this
--      project's standing practice of building both sides of
--      a genuine methodological fork. This measure counts
--      every distinct product variant a customer bought,
--      treating different colorways/versions of the same base
--      item as separate products.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT stock_code) AS distinct_variants_purchased
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY distinct_variants_purchased DESC;

-- RESULT: Top customer 14911 at 2,546 distinct variants purchased --
-- the same customer who leads every other completed-orders field in
-- this project (frequency: 373, monetary gross: $272,252.79 per Query
-- 67). 5,852 rows total, matching the completed-only population
-- established across Fields 2-4. Values range from 2,546 down to 1
-- (customers who purchased a single distinct product across their
-- entire completed order history).

-- CONFIRMED FINDING: Product diversity at the variant level is built
-- correctly against the same completed-only population as every
-- other field in this chapter. Customer 14911's consistent dominance
-- across frequency, monetary value, and now diversity suggests this
-- is a genuinely high-volume, broad-catalog customer rather than an
-- artifact specific to one measure. This is the first of two
-- diversity definitions -- see the next query for the family-level
-- version, which should collapse casing/trailing-letter variants
-- (per the Chapter One casing work, Queries 02-05) into their base
-- product before counting, testing whether variant-level diversity
-- overstates true product-line breadth.