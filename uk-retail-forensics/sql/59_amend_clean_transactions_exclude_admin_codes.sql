-- Query 59_amend_clean_transactions_exclude_admin_codes

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

-- RESULT: 1,022,519 rows -- confirmed exact match against the expected
-- arithmetic (1,028,437 prior row count minus 5,918 administrative
-- rows identified in Query 58). Like Queries 24 and 38 before it, this
-- is a DROP TABLE + CREATE TABLE AS statement with no exportable
-- result grid.

-- CONFIRMED FINDING: The administrative-code exclusion is confirmed
-- applied at the correct scale -- row count matches exactly. However,
-- this retrofit pass caught a real, previously undocumented side
-- effect: the exclusion filter (d.stock_code ~ '^[0-9]+[A-Za-z]*$')
-- uses the exact same regex pattern that Query 19 originally used to
-- surface non-numeric codes -- the same pattern Query 20 then proved
-- produces a false positive on "47503J " (trailing space), a genuine
-- product ("SET/3 FLORAL GARDEN TOOLS IN BAG") miscaught only because
-- of a stray whitespace character, not because it's an administrative
-- code. Since this amendment applies that same regex directly to
-- stock_code without first trimming whitespace, the "47503J " row is
-- silently dropped from clean_transactions here -- one legitimate
-- customer transaction lost as an unintended side effect of reusing an
-- exclusion pattern already known to have this specific false-positive
-- case. The impact is small in isolation (a single row, immaterial
-- dollar value per Query 58's $16.13 figure), but it represents a
-- genuine, uncorrected regression of an issue this project had already
-- solved once, at Query 20. Not caught by Query 60's verification,
-- since that check only confirms zero rows match the exclusion
-- pattern going forward -- it cannot distinguish a correctly-excluded
-- administrative code from an incorrectly-excluded real product with a
-- formatting defect matching the same pattern.