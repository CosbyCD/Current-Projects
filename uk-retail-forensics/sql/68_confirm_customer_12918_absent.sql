-- Query 68_confirm_customer_12918_absent

-- ============================================================
-- VERIFICATION: Confirm customer 12918 fully absent from
--               monetary_gross rebuild
-- WHAT: Directly checks whether customer 12918 appears anywhere
--       in the amended clean_transactions at all.
-- WHY: Customer 12918 was confirmed in query 63 as one of the
--      66 customers whose entire transaction history was
--      administrative activity (three "Manual" entries). Rather
--      than assuming their absence from query 67's excerpt,
--      confirming directly that zero rows remain for them
--      post-amendment.
-- ============================================================
SELECT COUNT(*) AS remaining_rows
FROM uk_retail.clean_transactions
WHERE customer_id = '12918';

-- RESULT: 0 -- confirmed directly, not inferred from Query 67's
-- absence alone. No rows for customer 12918 remain anywhere in the
-- amended clean_transactions.

-- CONFIRMED FINDING: PASSED. Customer 12918's complete removal is
-- verified by direct query, not just assumed from their absence in
-- Query 67's monetary_gross result. This closes the individual-
-- customer verification loop opened at Query 57 (the original
-- exact-mirror investigation) with full certainty: the three
-- administrative "Manual" entries that constituted this customer's
-- entire recorded history are gone, and so is the customer.