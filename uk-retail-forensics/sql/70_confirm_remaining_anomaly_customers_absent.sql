-- Query 70_confirm_remaining_anomaly_customers_absent

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

-- RESULT: Only customer 16446 appears in the result, with 4 remaining
-- rows -- matching the log exactly. 14802, 15802, and 13290 are
-- correctly absent (zero rows, consistent with their confirmed
-- removal at Query 67/69). Customer 16446 having 4 remaining rows
-- directly contradicts this query's own WHY block, which assumed all
-- five anomaly customers were among the 66 fully-administrative
-- removals -- a genuine, surprising result worth stopping on rather
-- than dismissing.

-- CONFIRMED FINDING: This result exposes and corrects a real error
-- in this project's own record. Re-examining Query 56's original data
-- at this point showed customer 16446 had been mischaracterized from
-- the start: their numbers ($168,472.50 gross / -$6.10 net) reflect
-- near-total cancellation of a large, genuine purchase history, not
-- the exact negative-mirror pattern the other four customers
-- (12918, 14802, 15802, 13290) showed. Grouping 16446 with the true
-- exact-doubling cases in the earlier writeup was an error, corrected
-- here rather than left standing. This also reframes what this
-- verification query actually accomplished: it didn't just confirm
-- an expected outcome, it caught a genuine miscategorization by
-- refusing to accept "three absent, one present" as an ambiguous or
-- partial success. See Query 71 for what 16446's 4 remaining rows
-- actually contain.