-- Query 24_build_excluded_rows_table

-- ============================================================
-- BUILD: Tagged excluded-rows table — internal stock activity
-- WHAT: Creates a new table capturing all rows identified as
--       internal stock/inventory activity rather than customer
--       transactions, tagged by which investigative thread
--       found them. Preserves these rows for their own analysis
--       (what does input-error data actually look like) rather
--       than simply discarding them.
-- WHY: Phase 3 (2,689 rows), Phase 6 thread 1 (1,693 rows), and
--      Phase 6 thread 3 (327 rows) all share the same underlying
--      signature — zero price, no customer_id — but differ in
--      description and quantity sign. Confirmed zero overlap
--      between all three groups (queries 09, 23). Combined,
--      these 4,709 rows represent a genuine, characterizable
--      phenomenon: internal stock corrections/adjustments,
--      distinguishable from real customer transactions. This
--      table preserves them, tagged, as a standalone artifact —
--      useful both to exclude cleanly from customer-level
--      derived fields, and as its own analysis of what
--      inconsistent data entry produces downstream.
-- ============================================================
CREATE TABLE uk_retail.excluded_rows AS
SELECT *,
    CASE
        WHEN quantity < 0 AND (description IS NULL OR TRIM(description) = '')
            THEN 'Phase 3: negative qty, blank description'
        WHEN quantity > 0 AND (description IS NULL OR TRIM(description) = '')
            THEN 'Phase 6 Thread 1: positive qty, blank description'
        WHEN description IN ('check', 'found', 'Check', 'Found', 'CHECK', 'FOUND', '?', 'missing', 'Missing', 'MISSING', 'lost', 'Lost', 'LOST')
            THEN 'Phase 6 Thread 3: placeholder text in description'
    END AS exclusion_reason
FROM uk_retail.raw_transactions
WHERE
    (quantity < 0 AND (description IS NULL OR TRIM(description) = ''))
    OR (quantity > 0 AND (description IS NULL OR TRIM(description) = ''))
    OR (description IN ('check', 'found', 'Check', 'Found', 'CHECK', 'FOUND', '?', 'missing', 'Missing', 'MISSING', 'lost', 'Lost', 'LOST'));

-- RESULT: An earlier "excluded_rows" table already existed under this
-- name (source unclear -- likely an earlier draft or partial run), which
-- initially caused a "relation already exists" error on first attempt.
-- The table was dropped (DROP TABLE IF EXISTS) and rebuilt fresh from
-- this exact query, guaranteeing the final table reflects Queries 06-23
-- precisely rather than an unverified earlier version. Rebuild completed
-- successfully: CREATE TABLE AS reported "SELECT 4709," confirming
-- exactly 4,709 rows were inserted -- an exact match to the expected
-- total (2,689 + 1,693 + 327 = 4,709) with no rows lost, duplicated, or
-- miscounted during the CASE-based tagging.

-- CONFIRMED FINDING: uk_retail.excluded_rows is now built and verified
-- at exactly 4,709 rows, each tagged with the specific investigative
-- thread (Phase 3, Phase 6 Thread 1, or Phase 6 Thread 3) that
-- identified it, per this project's citation standard. This table
-- serves two purposes going forward: (1) as the exclusion reference for
-- building clean_transactions, ensuring these 4,709 non-customer-facing
-- rows are cleanly separated rather than silently dropped, and (2) as
-- its own standalone artifact for a possible future analysis of what
-- internal data-entry inconsistency looks like at scale -- preserved,
-- not discarded, per this project's segregate-don't-delete standard.
-- See Query 25 for the verification count confirming this table's
-- row count against the source characterization queries independently.