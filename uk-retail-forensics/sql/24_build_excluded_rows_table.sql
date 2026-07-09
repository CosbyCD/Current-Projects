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