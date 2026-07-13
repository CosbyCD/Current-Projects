-- ============================================================
-- VERIFICATION: clean_transactions — customer_id formatting spot-check
-- WHAT: Confirms no customer_id value in clean_transactions
--       retains the trailing ".0" float-formatting artifact, and
--       no empty-string customer_id values remain (should be
--       true NULL instead, per the NULLIF logic in query 38).
-- WHY: Part of the verification/audit pass. Confirms the
--      customer_id normalization rule was actually applied
--      correctly at the row level, not just assumed from the
--      row count.
-- RESULT: 0 rows — confirmed pass. No trailing decimals, no
--      empty strings remain in customer_id. Like query 41, this
--      query has no matching file in /output/, since a zero-row
--      result produces no exportable data grid; documented here
--      instead.
-- ============================================================
SELECT DISTINCT customer_id FROM uk_retail.clean_transactions
WHERE customer_id LIKE '%.0' OR customer_id = ''
LIMIT 5;