-- Query 74_amend_clean_transactions_exclude_23843

-- ============================================================
-- AMENDMENT: clean_transactions — exclude the 80,995-unit
--            confirmed data entry error (stock_code 23843)
-- WHAT: Rebuilds clean_transactions a third time, adding one
--       more specific exclusion: both rows tied to invoice
--       581483/C581484 (customer 16446, stock_code 23843,
--       80,995 units), confirmed in queries 71-73 as a genuine
--       data entry error — the only two rows ever recorded for
--       this stock code in the entire raw dataset, purchased
--       and self-cancelled twelve minutes apart on the
--       dataset's final recorded day.
-- WHY: Even though this transaction nets to zero and doesn't
--      distort monetary_net, it still inflates monetary_gross
--      and frequency (both the completed-orders and all-orders
--      counts), since it carries a real invoice number and
--      passes every existing exclusion rule. Following the same
--      precedent as the original 12,540-unit outlier (Chapter
--      One): confirmed data entry errors get excluded
--      individually and explicitly, regardless of their net
--      dollar effect, because "doesn't affect the total" is not
--      the same as "didn't happen" — the row is factually wrong
--      and shouldn't be trusted in any downstream calculation.
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
    AND NOT (d.stock_code = '23843')
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

-- RESULT: 1,022,517 rows -- confirmed exact match to the expected
-- arithmetic (1,022,519 pre-amendment minus 2 rows for the excluded
-- stock_code 23843 pair). Like Queries 24, 38, and 59 before it, this
-- is a DROP TABLE + CREATE TABLE AS statement with no exportable
-- result grid.

-- CONFIRMED FINDING: The third amendment to clean_transactions is
-- confirmed applied at exactly the expected scale -- a precise,
-- individually-targeted two-row exclusion, not a broad pattern rule.
-- This continues the same precedent set in Chapter One (the 12,540-
-- unit outlier) and reinforces this project's standing principle that
-- a transaction netting to zero dollars is not the same as a
-- transaction that never happened -- it still corrupts gross and
-- frequency counts and must be excluded on its own facts, not
-- excused because the bottom line looks unaffected. This amendment
-- invalidates the row-level correctness of Fields 1 (Recency),
-- 2 (Frequency), and 3 (Monetary Value) as rebuilt against the second
-- amendment -- all three require one more rebuild pass before Chapter
-- Two can proceed to Field 4.