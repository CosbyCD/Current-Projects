-- ============================================================
-- CHAPTER TWO, FIELD 3: Monetary Value — gross (completed only)
-- WHAT: Sums quantity × unit_price for each customer, counting
--       only completed (non-cancelled) transaction lines.
-- WHY: First of two monetary value definitions, following the
--      same both-sides practice established with frequency.
--      Gross reflects total purchase value before accounting
--      for any later cancellations/returns.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY monetary_gross DESC;