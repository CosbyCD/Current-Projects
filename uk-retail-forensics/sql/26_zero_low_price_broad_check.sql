-- ============================================================
-- INVESTIGATION: Zero/unusually low unit_price rows — broad check
-- WHAT: Checks the full raw_transactions table for zero or very
--       low unit_price values, excluding rows already captured
--       and tagged in excluded_rows, to see if a distinct,
--       uncharacterized pattern exists among rows that DO have
--       a real description and/or customer_id.
-- WHY: All prior zero-price findings (Phase 3, Thread 1, Thread
--      3) were tied to blank or placeholder descriptions and no
--      customer_id. This checks whether zero/low price shows up
--      independently of those patterns — i.e., a real-looking
--      transaction (has description, has customer) with a
--      suspiciously low or zero price.
-- ============================================================
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_price,
    COUNT(*) FILTER (WHERE unit_price > 0 AND unit_price < 0.10) AS under_10p,
    COUNT(*) FILTER (WHERE unit_price >= 0.10 AND unit_price < 0.50) AS ten_to_49p
FROM uk_retail.raw_transactions r
WHERE NOT EXISTS (
    SELECT 1 FROM uk_retail.excluded_rows e
    WHERE e.invoice_no = r.invoice_no
    AND e.stock_code = r.stock_code
    AND e.invoice_date = r.invoice_date
)
AND unit_price < 0.50;