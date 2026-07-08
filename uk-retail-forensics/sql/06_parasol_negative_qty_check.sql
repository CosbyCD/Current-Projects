-- ============================================================
-- FINDING: Negative quantity with blank description — spot check
-- WHAT: Pulls full transaction history for stock_code 15044B
--       to directly compare a genuine cancellation (invoice
--       C554905) against the anomalous negative-quantity row
--       (invoice 556012) sitting in the same product's history.
-- WHY: Original query filtered by an incorrect customer_id
--      and returned nothing. Pulling the full stock code
--      history instead reveals both patterns side by side:
--      the real cancellation has a 'C' prefix, populated
--      description, real price, and valid customer_id; the
--      anomalous row has none of those.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE stock_code = '15044B'
ORDER BY invoice_date;