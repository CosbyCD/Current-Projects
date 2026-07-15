-- ============================================================
-- FOLLOW-UP: Customer 16446 — why 4 rows remain post-amendment
-- WHAT: Pulls the 4 remaining rows for customer 16446 directly,
--       to see what they are now that administrative codes have
--       been excluded.
-- WHY: Query 70 showed 16446 still has 4 rows post-amendment,
--       unlike 12918, 14802, 15802, and 13290. Re-examining the
--       original query 56 data shows 16446 was mischaracterized
--       earlier as part of the "exact-doubling" anomaly group —
--       their numbers ($168,472.50 gross / -$6.10 net) show
--       near-total cancellation, not the exact negative-mirror
--       pattern the other four customers showed. This checks
--       what's actually driving their numbers now.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, invoice_date
FROM uk_retail.clean_transactions
WHERE customer_id = '16446'
ORDER BY invoice_date;