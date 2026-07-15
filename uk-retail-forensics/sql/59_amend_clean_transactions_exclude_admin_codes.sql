-- ============================================================
-- AMENDMENT: clean_transactions — exclude administrative stock
--            codes (POST, DOT, M, C2, BANK CHARGES, etc.)
-- WHAT: Rebuilds clean_transactions to additionally exclude all
--       rows with non-numeric administrative stock codes,
--       identified and scoped in Chapter One (queries 19-23)
--       but never actually excluded from the table itself.
-- WHY: Query 57 found customer 12918's negative monetary_net
--      was caused by three "Manual" (stock_code = 'M') entries,
--      not real purchases. Query 58 confirmed this is a broader
--      gap: 6,091+ rows across POST, DOT, M, C2, BANK CHARGES,
--      AMAZONFEE, and other administrative codes remain in
--      clean_transactions, worth hundreds of thousands of
--      dollars combined, corrupting monetary value and likely
--      frequency for any customer who has one attributed to
--      them. This must be fixed at the source table, not
--      patched per-field, to keep every derived field consistent.
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
    AND d.stock_code ~ '^[0-9]+[A-Za-z]*$'
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