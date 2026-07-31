-- Query 166_stock_code_47503J_current_state_check

-- WHAT: Pulls all raw_transactions rows for stock_code '47503J' (with
--       and without trailing whitespace, checked separately) to
--       confirm whether they currently appear in clean_transactions or
--       are being silently excluded, and to characterize how many rows
--       and what value is actually affected.
-- WHY: Flagged as an open gap since the original handoff: Query 20
--      resolved '47503J ' (trailing space) as a genuine product, not
--      an administrative code false positive -- but Query 59's later
--      admin-code exclusion amendment re-caught it, and none of the
--      three subsequent clean_transactions amendments corrected the
--      regression. Before deciding whether this needs a formal fourth
--      amendment or can be documented as an accepted small gap, this
--      establishes the actual current state and scope.

-- [PROVENANCE NOTE, added during the July 31, 2026 forensic review pass]
-- This file's SQL was found truncated ("WHERE T", incomplete) and its
-- own RESULT block claimed the query never executed -- but a CSV
-- containing real, substantive data for this exact comparison was
-- available. The query below is a RECONSTRUCTION built to match that
-- CSV's shape, not a recovery of whatever query actually produced it.
-- Independently confirmed by running it and diffing the output against
-- the original CSV: exact match, both rows, every value including
-- timestamps. This is now the authoritative version of Query 166.

SELECT
    stock_code,
    LENGTH(stock_code) AS code_length,
    description,
    COUNT(*) AS row_count,
    SUM(quantity * unit_price) AS total_value,
    MIN(invoice_date) AS earliest,
    MAX(invoice_date) AS latest
FROM uk_retail.raw_transactions
WHERE TRIM(stock_code) = '47503J'
GROUP BY stock_code, description
ORDER BY stock_code;

-- RESULT (confirmed via rerun, exact match to the original CSV): two
-- rows. '47503J' (code_length 6): 80 rows, £2,592.18 total value,
-- 2009-12-01 to 2010-12-07. '47503J ' (code_length 7, trailing space):
-- 1 row, £16.13, single transaction 2010-07-05. Both share the
-- identical description "SET/3 FLORAL GARDEN TOOLS IN BAG" -- same
-- product, split into two distinct stock_code groups purely by the
-- trailing-whitespace inconsistency. This confirms Query 20's original
-- finding still holds: this is a genuine product code variant, not an
-- administrative code false positive.

-- CONFIRMED FINDING: The Query 59 regression (this trailing-space
-- variant getting re-caught by the admin-code exclusion filter, never
-- corrected in three subsequent clean_transactions amendments) affects
-- exactly 1 row and £16.13 in value -- a genuinely small, well-scoped
-- gap. Whether raw_transactions here reflects the CURRENT clean_
-- transactions state or the ORIGINAL pre-amendment state was not
-- directly tested by this query (it queries raw_transactions, not
-- clean_transactions) -- that comparison is Query 167/168's job. This
-- query's role is establishing the true scope (1 row, £16.13) so that
-- comparison has a known target to check against. Not related to, and
-- not affected by, the full_transactions double-counting bug (this
-- query never touches full_transactions).