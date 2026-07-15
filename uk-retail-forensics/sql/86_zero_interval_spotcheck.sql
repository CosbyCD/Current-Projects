-- ============================================================
-- VERIFICATION: Zero-day interval cluster — spot-check
-- WHAT: Pulls the actual invoice numbers and timestamps for one
--       customer showing orders_used_in_calc > 1 with
--       avg_days_between_orders = 0.0, to confirm this reflects
--       genuine same-day repeat orders rather than a data or
--       query artifact.
-- WHY: Query 85 showed a large cluster of customers with a
--      0.0-day average interval. Worth confirming directly
--      before accepting the field as final, consistent with
--      this project's standard practice.
-- ============================================================
SELECT invoice_no, MIN(invoice_date) AS order_time
FROM uk_retail.clean_transactions
WHERE customer_id = '18139'
AND invoice_no NOT LIKE 'C%'
GROUP BY invoice_no
ORDER BY order_time;