-- ============================================================
-- VERIFICATION: Monetary net rebuild v3 — customer 16446 spot-check
-- WHAT: Directly confirms customer 16446's monetary_net after
--       the third table amendment (query 74), which excluded
--       both the 80,995-unit purchase and its matching
--       cancellation for stock_code 23843.
-- WHY: Since the purchase (+£168,469.60) and cancellation
--      (−£168,469.60) exactly offset each other, removing both
--      should leave monetary_net essentially unchanged —
--      confirming this amendment mattered for monetary_gross
--      and frequency, but not for monetary_net. Verified
--      directly rather than assumed.
-- ============================================================
SELECT customer_id, ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_net
FROM uk_retail.clean_transactions
WHERE customer_id = '16446'
GROUP BY customer_id;