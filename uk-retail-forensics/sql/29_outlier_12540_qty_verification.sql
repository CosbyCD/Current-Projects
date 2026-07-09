-- ============================================================
-- FOLLOW-UP: Verify the 12,540-quantity zero-price outlier
-- WHAT: Pulls the full transaction history for stock_code 84826
--       and customer_id 13256 to see this row in context —
--       is a 12,540-unit giveaway at zero price plausible, or
--       does it look like a data entry error (e.g., misplaced
--       decimal, phantom quantity)?
-- WHY: Query 28 flagged invoice 578841 (84826, qty 12540, price
--      £0.00, customer 13256) as requiring individual
--      verification before deciding how to treat it — an
--      outlier of this size could materially distort that
--      customer's derived fields if it's a genuine error.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE (stock_code = '84826' OR customer_id = '13256')
ORDER BY invoice_date;