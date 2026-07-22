-- Query 82_monetary_gross_16446_spotcheck

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
-- ============================================================
SELECT customer_id, ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id = '16446'
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id;

-- RESULT: $2.90 -- confirmed directly, matching the expected combined
-- value of the two legitimate items exactly ($1.65 + $1.25).

-- CONFIRMED FINDING: PASSED. Customer 16446's monetary_gross is
-- verified correct by direct individual query, not inferred from
-- Query 81's sorted aggregate alone. This closes the individual-
-- customer verification loop opened at Query 70 with full certainty:
-- from an unexpected 4-remaining-rows result, through row-level
-- investigation (71), scope verification (72-73), targeted exclusion
-- (74-75), and now confirmed correct at both the aggregate (81) and
-- individual (82) level. See Query 83 for the matching net rebuild.