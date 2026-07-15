-- ============================================================
-- VERIFICATION: Monetary gross rebuild v3 — customer 16446 spot-check
-- WHAT: Directly confirms customer 16446's monetary_gross after
--       the third table amendment (query 74), which excluded
--       their 80,995-unit stock_code 23843 transaction.
-- WHY: Rather than inferring from their absence at the top of
--      query 81's sorted result, confirming the exact figure
--      directly. Their gross value should now reflect only the
--      two legitimate items from invoice 553573 (pantry
--      scrubbing brush, £1.65 + pantry pastry brush, £1.25).
-- RESULT: $2.90 — confirmed. Matches the expected combined
--      value of the two legitimate items exactly.
-- ============================================================
SELECT customer_id, ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id = '16446'
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id;