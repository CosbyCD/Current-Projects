-- ============================================================
-- VERIFICATION: Customers who disappeared after the amendment
-- WHAT: Identifies exactly which 66 customer_ids existed before
--       the administrative-code amendment (query 59) but no
--       longer appear in the amended clean_transactions.
-- WHY: Confirms the missing customers are legitimately gone
--      because their entire transaction history was
--      administrative activity, not evidence of an error in
--      the amendment itself.
-- ============================================================
SELECT customer_id, COUNT(*) AS admin_rows, ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS total_admin_value
FROM uk_retail.raw_transactions
WHERE customer_id IS NOT NULL
AND stock_code !~ '^[0-9]+[A-Za-z]*$'
AND NULLIF(REGEXP_REPLACE(customer_id, '\.0$', ''), '') NOT IN (
    SELECT DISTINCT customer_id FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL
)
GROUP BY customer_id
ORDER BY admin_rows DESC;