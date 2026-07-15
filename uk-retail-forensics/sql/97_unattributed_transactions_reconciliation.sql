-- ============================================================
-- VERIFICATION: unattributed_transactions row count reconciliation
-- WHAT: Directly re-confirms the no-customer-ID row count against
--       clean_transactions itself, independent of query 96's
--       CREATE TABLE AS result, before accepting 228,297 as final.
-- WHY: Query 96 returned 228,297 rows instead of the originally
--      reported 243,007 (established in Phase 5, query 14,
--      against raw_transactions before deduplication and three
--      subsequent clean_transactions amendments). This confirms
--      the number directly rather than trusting the CREATE
--      TABLE result alone.
-- RESULT: 228,297 — confirmed, matching query 96 exactly. The
--      14,710-row gap from the original 243,007 figure is fully
--      explained: those rows were removed from clean_transactions
--      for other, already-documented reasons (deduplication,
--      administrative-code exclusion, the confirmed outlier)
--      before ever reaching this segregation step.
-- ============================================================
SELECT COUNT(*) AS original_no_customer_id_still_present
FROM uk_retail.clean_transactions
WHERE customer_id IS NULL;