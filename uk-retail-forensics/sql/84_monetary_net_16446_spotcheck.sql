-- Query 84_monetary_net_16446_spotcheck

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

-- RESULT: $2.90 -- confirmed directly, identical to their net value
-- before this amendment (Query 69).

-- CONFIRMED FINDING: PASSED. Customer 16446's monetary_net is
-- verified unchanged by direct individual query, confirming the
-- predicted asymmetry from Query 83: this amendment mattered for
-- monetary_gross (dropped from $168,472.50 to $2.90) and both
-- frequency components, but had zero effect on monetary_net, since a
-- purchase and its exact-match cancellation always net to zero
-- whether present or removed together. This closes Field 3 (Monetary
-- Value)'s full verification arc across all three amendments (54-58
-- original, 67-70 second rebuild, 81-84 third rebuild) with complete
-- confidence -- monetary_gross and monetary_net now reflect genuine
-- customer purchasing behavior only, fully reconciled against the
-- final clean_transactions table. Chapter Two's first three fields
-- (Recency, Frequency, Monetary Value) are all finalized.