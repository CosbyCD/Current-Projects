-- ============================================================
-- CHAPTER TWO, FIELD 3: Monetary Value — comparison of both definitions
-- WHAT: Combines monetary_gross (query 54) and monetary_net
--       (query 55) into one result, with the dollar gap between
--       them per customer.
-- WHY: Following this project's established both-sides practice
--      (return rate, frequency). The gap column shows exactly
--      how much cancelled/returned value affected each
--      customer's totals — a direct dollar analog to
--      frequency's cancellation_count.
-- ============================================================
SELECT
    a.customer_id,
    a.monetary_gross,
    b.monetary_net,
    ROUND((a.monetary_gross - b.monetary_net)::NUMERIC, 2) AS cancelled_value
FROM (
    SELECT customer_id, ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%'
    GROUP BY customer_id
) a
JOIN (
    SELECT customer_id, ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_net
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) b ON a.customer_id = b.customer_id
ORDER BY cancelled_value DESC;