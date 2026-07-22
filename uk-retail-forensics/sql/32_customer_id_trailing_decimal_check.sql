-- Query 32_customer_id_trailing_decimal_check

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

-- RESULT: total_with_customer_id = 824,364; has_trailing_decimal =
-- 824,364 (100%); no_trailing_decimal = 0. Every single non-blank
-- customer_id value in the dataset carries the trailing ".0" --
-- confirmed with zero exceptions.

-- CONFIRMED FINDING: The trailing-decimal formatting is fully and
-- uniformly consistent across all 824,364 populated customer_id rows --
-- this is not an inconsistent, silently-corrupting risk as initially
-- feared when Query 31's exact-match search first failed, but a
-- uniform import artifact from the source CSV (customer_id was read as
-- a float rather than a string/integer type). Because the pattern is
-- 100% consistent with no exceptions, no row is at risk of being
-- silently missed by a query that assumes the trailing decimal is
-- present -- the actual risk runs the other direction: any query
-- written WITHOUT accounting for the ".0" (as Query 31's first attempt
-- was) will silently return zero rows rather than erroring, which is
-- exactly what happened. This is a real, dataset-wide formatting defect
-- that must be resolved -- customer_id should be cast to a clean
-- integer or string form (stripping the trailing ".0") when building
-- clean_transactions, both for readability and to remove this
-- silent-failure risk from every future query written against the
-- clean table. Confirmed as fully consistent, not intermittent, closes
-- the question Query 31's initial failed search raised.