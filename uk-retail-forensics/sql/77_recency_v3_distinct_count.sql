-- Query 77_recency_v3_distinct_count

-- ============================================================
-- VERIFICATION: Recency rebuild v3 — distinct customer count
-- WHAT: Confirms the distinct customer count after the third
--       amendment (query 74), and checks whether it changed
--       from the second-amendment figure of 5,875.
-- WHY: Same verify-before-trusting discipline applied at every
--      prior amendment. Since customer 16446 still exists in
--      the table (they had other legitimate transactions
--      beyond the excluded 23843 rows), the count should stay
--      at 5,875 — this confirms no customer was fully removed
--      by the third amendment the way 66 were by the second.
-- ============================================================
SELECT COUNT(DISTINCT customer_id) FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL;

-- RESULT: 5,875 -- confirmed unchanged from the second-amendment
-- figure, matching Query 76's own row count exactly.

-- CONFIRMED FINDING: PASSED. The third amendment removed two
-- transaction rows but zero customers -- confirming directly, not
-- assuming, that customer 16446 retained enough legitimate
-- transaction history to remain a real customer in the table. This
-- closes the Field 1 (Recency) verification arc for the third
-- amendment (76-77): rebuilt, spot-checked at the individual customer
-- level, and confirmed at the aggregate level, with both results in
-- full agreement. 5,875 is now the fully-reconciled customer count
-- for the remainder of Chapter Two.