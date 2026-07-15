-- ============================================================
-- CHAPTER TWO, FIELD 3: Monetary Value — net (all transactions)
-- WHAT: Sums quantity × unit_price for each customer across ALL
--       transaction lines, including cancellations. Cancelled
--       lines carry negative quantity, so they naturally reduce
--       the total.
-- WHY: Second of two monetary value definitions. Net reflects
--      actual retained spend after cancellations/returns are
--      accounted for.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_net
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary_net DESC;