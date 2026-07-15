-- ============================================================
-- CHAPTER TWO, FIELD 2: Frequency — all distinct orders
-- WHAT: Counts distinct orders per customer, INCLUDING
--       cancelled orders (invoice_no starting with 'C') as
--       their own distinct order events.
-- WHY: Second of two frequency definitions being built and
--      compared. This version treats frequency as a measure of
--      overall order-placing engagement/activity, regardless of
--      whether the order was ultimately completed or cancelled.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_all_orders
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY frequency_all_orders DESC;