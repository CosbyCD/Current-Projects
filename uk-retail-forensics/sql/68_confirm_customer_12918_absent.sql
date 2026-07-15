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