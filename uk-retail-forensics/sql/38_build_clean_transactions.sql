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