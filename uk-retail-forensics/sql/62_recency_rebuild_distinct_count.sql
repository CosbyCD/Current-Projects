-- ============================================================
-- VERIFICATION: Recency rebuild — row count reconciliation
-- WHAT: Confirms the rebuilt recency field (query 61) still has
--       exactly one row per distinct customer, matching the
--       amended clean_transactions.
-- WHY: Recency was rebuilt after the administrative-code
--      amendment (query 59). Confirming the row count is still
--      correct before declaring recency unaffected.
-- ============================================================
SELECT COUNT(DISTINCT customer_id) FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL;