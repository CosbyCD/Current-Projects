-- Query 43_clean_transactions_customerid_spotcheck

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
-- ============================================================
SELECT DISTINCT customer_id FROM uk_retail.clean_transactions
WHERE customer_id LIKE '%.0' OR customer_id = ''
LIMIT 5;

-- RESULT: 0 rows returned — confirmed pass. No customer_id value
-- retains the trailing ".0" artifact, and no empty-string values
-- remain (correctly converted to true NULL via the NULLIF logic in
-- Query 38). Like Query 41, this query has no matching file in
-- /output/, since a zero-row result produces no exportable data grid
-- — documented here directly instead.

-- CONFIRMED FINDING: PASSED. The customer_id normalization rule
-- (stripping the trailing ".0" float-formatting artifact and
-- converting the resulting empty string to true NULL, per Query 38)
-- is verified at the row level in the finished clean_transactions
-- table. This is the second of three direct row-level spot-checks run
-- as part of the Chapter One verification/audit pass, alongside Query
-- 42 (stock code casing, passed) and Query 44 (country normalization,
-- passed) — confirming clean_transactions is sound at both the
-- aggregate and row level before Chapter Two begins.