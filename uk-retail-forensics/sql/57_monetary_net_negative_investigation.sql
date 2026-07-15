-- ============================================================
-- FOLLOW-UP: Negative monetary_net anomaly — customer 12918
-- WHAT: Pulls the full transaction history for customer 12918,
--       whose monetary_net (-$10,953.50) is exactly the negative
--       mirror of their monetary_gross ($10,953.50) — meaning
--       their cancelled value ($21,907.00) is precisely double
--       their gross purchases.
-- WHY: Query 56 surfaced several customers with this same exact-
--      doubling pattern (16446, 12918, 14802, 15802, 13290),
--      which is too precise to be coincidence. Investigating one
--      case directly, same discipline as the 12,540-quantity
--      outlier in Chapter One, before deciding how the final
--      monetary value field should handle this pattern.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price,
       ROUND((quantity * unit_price)::NUMERIC, 2) AS line_value,
       invoice_date
FROM uk_retail.clean_transactions
WHERE customer_id = '12918'
ORDER BY invoice_date;