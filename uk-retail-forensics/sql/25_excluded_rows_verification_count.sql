-- Query 25_excluded_rows_verification_count

-- ============================================================
-- VERIFICATION: Excluded-rows table — per-category count check
-- WHAT: Confirms the excluded_rows table's exclusion_reason
--       tags break down into exactly the three expected
--       category counts established across Queries 06-23.
-- WHY: Query 24's CREATE TABLE AS confirmed 4,709 total rows,
--      but that alone doesn't confirm the CASE logic tagged
--      each row correctly -- a bug in the CASE conditions could
--      still produce the right total with rows miscategorized
--      between groups. This checks each category independently.
-- ============================================================
SELECT exclusion_reason, COUNT(*)
FROM uk_retail.excluded_rows
GROUP BY exclusion_reason
ORDER BY COUNT(*) DESC;

-- RESULT: Exact match across all three categories with no
-- discrepancies: "Phase 3: negative qty, blank description" = 2,689
-- (matching Query 07's full-scale count exactly); "Phase 6 Thread 1:
-- positive qty, blank description" = 1,693 (matching Query 15/16's
-- verified count exactly); "Phase 6 Thread 3: placeholder text in
-- description" = 327 (matching Query 21's count exactly). Sum of the
-- three: 2,689 + 1,693 + 327 = 4,709, matching Query 24's reported
-- insert count precisely. No unexpected NULL exclusion_reason values
-- appeared, confirming the CASE statement's WHERE clause and CASE
-- conditions are in full agreement -- every row that matched the WHERE
-- clause was successfully tagged by exactly one of the three CASE
-- branches, with no fall-through gaps.

-- CONFIRMED FINDING: The excluded_rows table is fully verified, not
-- just at the aggregate level (Query 24) but per-category: each of the
-- three exclusion reasons contains exactly the row count independently
-- established by its originating investigation (Queries 07, 15/16, and
-- 21 respectively), with perfect internal consistency between the
-- WHERE clause and the CASE tagging logic. This closes the excluded-
-- rows construction thread (06 through 25) with full confidence -- the
-- table is ready to serve as the authoritative exclusion reference for
-- building clean_transactions, and its provenance is fully traceable
-- back to the specific query that discovered each row category.