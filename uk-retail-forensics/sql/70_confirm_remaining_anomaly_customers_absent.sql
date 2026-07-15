-- ============================================================
-- VERIFICATION: Confirm remaining exact-doubling anomaly
--               customers resolved
-- WHAT: Checks whether the other four customers from query 56's
--       exact-doubling finding (16446, 14802, 15802, 13290) —
--       beyond the already-confirmed-absent 12918 — still exist
--       in the amended clean_transactions, and if so, whether
--       their monetary_net is still an exact negative mirror of
--       monetary_gross.
-- WHY: Query 63 already confirmed all five anomaly customers
--      were among the 66 fully-administrative customers. This
--      directly verifies that conclusion against the actual
--      rebuilt monetary fields, rather than assuming it follows.
-- ============================================================
SELECT customer_id, COUNT(*) AS remaining_rows
FROM uk_retail.clean_transactions
WHERE customer_id IN ('16446', '14802', '15802', '13290')
GROUP BY customer_id;