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