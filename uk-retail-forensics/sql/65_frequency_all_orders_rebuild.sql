-- Query 65_frequency_all_orders_rebuild

-- ============================================================
-- CHAPTER TWO, FIELD 2 REBUILD: Frequency — all distinct orders
-- WHAT: Re-runs the all-distinct-orders frequency (originally
--       query 51) against the amended clean_transactions.
-- WHY: Same rebuild rationale as query 64 — confirming
--       administrative-code invoice numbers aren't inflating
--       the all-orders count either.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_all_orders
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY frequency_all_orders DESC;

-- RESULT: Top customer 14911 dropped from 510 (Query 51) to 466,
-- matching the log exactly -- a reduction of 44 administrative
-- invoice numbers. 5,875 rows returned, the full current customer
-- population (confirmed at Query 62), consistent with this query
-- having no cancellation or completed-order filter -- every customer
-- with at least one remaining order of any kind appears here.

-- CONFIRMED FINDING: Frequency (all distinct orders) successfully
-- rebuilt against the amended table, top customer confirmed against
-- the log. This field naturally covers the full 5,875-customer
-- population without needing a special join consideration, the same
-- pattern already established at the original Query 51 relative to
-- Query 50. Sets up Query 66's rebuilt comparison of both frequency
-- definitions against the amended table.