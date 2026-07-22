-- Query 38_build_clean_transactions

-- ============================================================
-- BUILD: clean_transactions — the working dataset for the six
--        derived customer behavior fields
-- WHAT: Builds uk_retail.clean_transactions from raw_transactions,
--       applying every finding from Phase 2 and Phase 6, plus
--       the deduplication policy confirmed via queries 36-37.
--       raw_transactions remains completely untouched.
-- WHY: Single, traceable point where every finding in this log
--      becomes an actual transformation rule:
--      - Deduplicates the 34,335 excess duplicate rows
--        (queries 17-18; policy confirmed safe via 36-37)
--      - Removes the 4,709 rows tagged in excluded_rows
--        (Phase 6, Threads 1-3), matched on every column
--      - Removes only the single confirmed bad line item from
--        the 12,540-quantity outlier (Thread 4, invoice 578841,
--        stock_code 84826) — not the whole invoice
--      - Normalizes stock code casing (Phase 2)
--      - Strips the trailing ".0" float artifact from
--        customer_id AND converts the resulting empty string to
--        true NULL, finally closing the original day-one
--        pending cleanup item that was superseded when the
--        "never modify raw_transactions directly" rule was
--        adopted
--      - Combines "Unspecified" and "European Community" into
--        one tracked category (Thread 5)
-- ============================================================
DROP TABLE IF EXISTS uk_retail.clean_transactions;

CREATE TABLE uk_retail.clean_transactions AS
WITH deduplicated AS (
    SELECT DISTINCT *
    FROM uk_retail.raw_transactions
),
excluded_removed AS (
    SELECT d.*
    FROM deduplicated d
    WHERE NOT EXISTS (
        SELECT 1 FROM uk_retail.excluded_rows e
        WHERE e.invoice_no = d.invoice_no
        AND e.stock_code = d.stock_code
        AND e.description IS NOT DISTINCT FROM d.description
        AND e.quantity = d.quantity
        AND e.unit_price = d.unit_price
        AND e.customer_id IS NOT DISTINCT FROM d.customer_id
        AND e.invoice_date = d.invoice_date
    )
    AND NOT (d.invoice_no = '578841' AND d.stock_code = '84826')
)
SELECT
    invoice_no,
    UPPER(stock_code) AS stock_code,
    description,
    quantity,
    unit_price,
    NULLIF(REGEXP_REPLACE(customer_id, '\.0$', ''), '') AS customer_id,
    CASE
        WHEN country IN ('Unspecified', 'European Community')
            THEN 'Unspecified-European Community'
        ELSE country
    END AS country,
    invoice_date
FROM excluded_removed;

-- RESULT: CREATE TABLE AS reported "SELECT 1028437" -- 1,028,437 rows
-- in the finished clean_transactions table. This is 111 rows MORE than
-- the naive expected count (1,067,371 raw - 34,335 duplicate excess -
-- 4,709 excluded - 1 outlier line = 1,028,326 expected). Like Query 24,
-- this query has no matching output file -- it is a CREATE TABLE AS
-- statement that builds a table directly rather than returning an
-- exportable result grid.

-- CONFIRMED FINDING: A real 111-row discrepancy exists between the
-- expected and actual clean_transactions count -- fully explained in
-- Query 39: excluded_rows itself was built (Query 24) before the
-- deduplication policy was finalized, and contains 111 internal
-- exact-duplicate rows. This query's `deduplicated` CTE runs first,
-- collapsing raw_transactions to one row per unique combination --
-- including collapsing those 111 duplicate pairs before the exclusion
-- filter ever sees them. The exclusion step therefore had fewer actual
-- rows to remove than the raw 4,709 count implied, producing exactly
-- 111 more final rows than the naive subtraction predicted. The
-- duplicate-row problem (Queries 17-18) and the internal-stock-activity
-- problem (Phase 6, Threads 1-3) turned out to be partially entangled
-- in a way not explicitly tested before this point -- the build handled
-- the overlap correctly by construction. clean_transactions at
-- 1,028,437 rows is confirmed fully reconciled and trustworthy (see
-- Query 39 for the direct verification). Note for later reference: the
-- real project amends this table twice more downstream -- once to
-- remove administrative stock codes still present despite Query 24's
-- exclusion logic, and once for a second, independently-discovered
-- outlier -- meaning this 1,028,437-row version is not the final state
-- of clean_transactions, only the first fully-reconciled one.