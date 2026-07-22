-- Query 67_monetary_gross_rebuild

-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD: Monetary Value — gross
-- WHAT: Re-runs monetary_gross (originally query 54) against
--       the amended clean_transactions.
-- WHY: Query 57 traced the exact-doubling anomaly (customer
--       12918 and others) to administrative "Manual" entries.
--       This rebuild should resolve that anomaly entirely,
--       since those rows are now excluded at the source.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY monetary_gross DESC;

-- RESULT: Top customer 18102 unchanged at $580,987.04, matching the
-- log exactly -- their gross purchases apparently included no
-- administrative-code contamination. 5,852 rows, matching Query 64's
-- completed-only population (same filter, same customer set). Directly
-- confirmed: all four customers Query 56 flagged as showing an exact
-- negative-mirror pattern (12918, 14802, 15802, 13290) are now
-- entirely ABSENT from this result -- consistent with Query 63's
-- finding that all four were among the 66 customers whose entire
-- history was administrative-only and correctly removed by this
-- amendment. Customer 16446, by contrast, is still present here at
-- $168,472.50 gross -- unchanged from Query 54 -- confirming 16446
-- retained genuine purchase history and was correctly NOT among the
-- 66 removed customers, consistent with Query 63's finding that
-- 16446's anomaly (near-total cancellation, not exact doubling) is a
-- different phenomenon from the other four.

-- CONFIRMED FINDING: The rebuild fully resolves the exact-mirror
-- anomaly for the four customers whose "purchases" were entirely
-- administrative -- they simply no longer appear in any customer-
-- level field, which is the correct outcome, not a gap needing further
-- handling. This closes the loop opened at Query 56 with direct,
-- positive confirmation: the mirror pattern was fully explained by
-- administrative contamination, and removing that contamination at
-- the source (Query 59) makes the anomaly disappear on its own,
-- exactly as predicted at Query 63. Customer 16446 remains a distinct,
-- still-open case -- present in the data with a real gross value,
-- its earlier near-total-cancellation anomaly not yet addressed by
-- this particular amendment.