-- ============================================================
-- FOLLOW-UP: Confirm scope — administrative stock codes still
--            present in clean_transactions
-- WHAT: Checks whether "M" (Manual) and other non-numeric
--       administrative stock codes are still present in
--       clean_transactions, contaminating customer-level
--       calculations like monetary value.
-- WHY: Query 57 found customer 12918's negative monetary_net is
--      caused entirely by three "Manual" (stock_code = 'M')
--      administrative entries, not real customer purchases.
--      Confirming whether this is isolated to a few customers
--      or a broader gap in the Chapter One exclusion logic.
-- ============================================================
SELECT stock_code, COUNT(*) AS occurrences,
       ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS total_value
FROM uk_retail.clean_transactions
WHERE stock_code !~ '^[0-9]+[A-Za-z]*$'
GROUP BY stock_code
ORDER BY occurrences DESC;