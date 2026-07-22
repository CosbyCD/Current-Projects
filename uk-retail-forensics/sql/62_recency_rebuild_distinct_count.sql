-- Query 62_recency_rebuild_distinct_count

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

-- RESULT: 5,875 -- confirmed real, not a fluke or discrepancy: down
-- from the pre-amendment 5,941 by exactly 66 customers. This is a
-- genuine change in the customer population, not a row-count mismatch
-- within the recency field itself -- Query 61's own result also
-- showed 5,875 rows, so recency and the distinct customer count agree
-- with each other; what's still open is why the underlying population
-- dropped by 66 in the first place.

-- CONFIRMED FINDING: The drop from 5,941 to 5,875 customers is
-- confirmed real and consistent across both the recency field (Query
-- 61) and a direct distinct-count check (this query) -- not a
-- reconciliation error. Per this project's standard, a real
-- population change of this size (66 customers, over 1% of the base)
-- gets investigated directly rather than accepted as a plausible-
-- sounding side effect of the administrative-code amendment. See Query
-- 63 for that investigation.