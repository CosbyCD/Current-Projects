-- ============================================================
-- CHAPTER TWO, FIELD 2: Frequency — completed orders only
-- WHAT: Counts distinct orders per customer, EXCLUDING
--       cancelled orders (invoice_no starting with 'C').
-- WHY: First of two frequency definitions being built and
--      compared, following this project's standard practice
--      (established with return rate in Chapter One) of testing
--      both sides of a genuine methodological question rather
--      than picking one blind. This version treats frequency as
--      a measure of actual completed purchasing behavior.
-- ============================================================
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS frequency_completed_only
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY frequency_completed_only DESC;