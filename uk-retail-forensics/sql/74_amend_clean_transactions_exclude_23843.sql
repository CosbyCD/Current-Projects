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