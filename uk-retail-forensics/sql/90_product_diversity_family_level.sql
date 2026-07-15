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