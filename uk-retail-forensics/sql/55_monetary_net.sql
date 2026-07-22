-- Query 55_monetary_net

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

-- RESULT: Top customer is 18102 at $570,380.61 -- roughly $10,600
-- lower than Query 54's gross figure for the same customer, matching
-- the log's expected cancellation-drag pattern exactly. 5,941 rows
-- returned, the full customer population (no cancellation filter, so
-- the 61 all-cancelled customers are included here, unlike Query 54's
-- 5,880-row gross version). Sort tail shows genuinely negative net
-- values -- customers whose cancelled value exceeded their completed
-- purchases -- descending to customer 17399 at -$25,111.09. Customer
-- 12918 appears at exactly -$10,953.50, precisely matching the
-- "exact negative mirror" figure the log attributes to this customer
-- at Query 56 (against their $10,953.50 gross value from Query 54) --
-- confirmed consistent across both queries independently.

-- CONFIRMED FINDING: Monetary Value (net, all transactions) built
-- successfully, top customer and cancellation-drag magnitude both
-- confirmed against the log. This field correctly covers the full
-- 5,941-customer population, in contrast to Query 54's narrower
-- completed-only version -- consistent with the same pattern already
-- established between Query 50 (completed-only frequency) and Query
-- 51 (all-orders frequency). The exact negative-mirror pattern on
-- customer 12918, visible directly in this raw sort without needing
-- a separate join, is what Query 56 will formally investigate and
-- generalize across multiple customers (16446, 12918, 14802, 15802,
-- 13290, per the log) as too precise to be ordinary cancellation
-- behavior.