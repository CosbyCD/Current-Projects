-- -- ============================================================
-- FOLLOW-UP: Transposition candidates — date proximity check
-- WHAT: Checks whether customer_id 13265 or 13526 (both plausible
--       digit-transposition candidates for 13256) placed any
--       orders close in time to the anomalous invoice 578841
--       (Nov 25, 2011), which would strengthen the case that one
--       of them is the row's true intended customer.
-- WHY: Query 40 showed "1 order" is common across this dataset,
--      weakening the original neighbor-count argument. However,
--      it also surfaced two real, established customers whose
--      IDs are one-digit-transposition away from 13256 — a much
--      more specific and testable signal than order count alone.
-- RESULT: 0 rows. Neither candidate placed any order in the
--      Nov 1 – Dec 15, 2011 window. This rules out the most
--      specific version of the transposition theory. Note: like
--      queries 24 and 38, this query has no matching file in
--      /output/ — not because it builds a table, but because a
--      zero-row result produces no exportable data grid in
--      pgAdmin. The result is documented here in the query file
--      itself instead.
-- ============================================================
SELECT customer_id, invoice_no, invoice_date
FROM uk_retail.raw_transactions
WHERE customer_id IN ('13265.0', '13526.0')
AND invoice_date BETWEEN '2011-11-01' AND '2011-12-15'
ORDER BY customer_id, invoice_date;