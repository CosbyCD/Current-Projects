-- ============================================================
-- FINDING: Customer_id trailing decimal formatting — full check
-- WHAT: Checks whether ALL customer_id values carry a trailing
--       ".0" (float-formatting artifact from import), or whether
--       this is inconsistent across the dataset.
-- WHY: Query 31 initially returned 0 rows searching for
--      customer_id = '13256', but succeeded searching for
--      '13256.0' — revealing customer_id is stored with a
--      trailing decimal. If this is inconsistent dataset-wide,
--      it's a serious risk: any future query or join on
--      customer_id could silently miss rows depending on
--      whether the decimal is included, exactly the kind of
--      thing that could quietly corrupt the six derived fields.
-- ============================================================
SELECT
    COUNT(*) AS total_with_customer_id,
    COUNT(*) FILTER (WHERE customer_id LIKE '%.0') AS has_trailing_decimal,
    COUNT(*) FILTER (WHERE customer_id NOT LIKE '%.0' AND TRIM(customer_id) != '') AS no_trailing_decimal
FROM uk_retail.raw_transactions
WHERE customer_id IS NOT NULL AND TRIM(customer_id) != '';