-- ============================================================
-- FINDING: Cross-check against 'C'-prefix cancellation flag
-- WHAT: Of the 2,689 negative-quantity/blank-description rows,
--       how many DO vs DON'T start with 'C' (the documented
--       cancellation marker).
-- WHY: Query 06 showed a genuine cancellation (C554905) sitting
--      right next to the anomalous row (556012) on the same
--      product — the anomalous row had no 'C' prefix. Testing
--      whether that holds across the full 2,689-row pattern,
--      or whether some of them are legitimate cancellations
--      that happen to also lack a description.
-- ============================================================
SELECT
    COUNT(*) AS total_negative_blank_desc,
    COUNT(*) FILTER (WHERE invoice_no LIKE 'C%') AS c_prefixed,
    COUNT(*) FILTER (WHERE invoice_no NOT LIKE 'C%') AS not_c_prefixed
FROM uk_retail.raw_transactions
WHERE quantity < 0
AND (description IS NULL OR TRIM(description) = '');