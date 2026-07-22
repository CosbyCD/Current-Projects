-- Query 56_monetary_comparison

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

-- RESULT: 5,880 rows (matching Query 54's completed-only population,
-- consistent with the inner join pattern already seen at Query 52).
-- Sorted by cancelled_value descending, customer 16446 tops the list
-- at $168,478.60 -- by far the largest gap in the dataset, roughly 6x
-- the next-largest. Customer 12918 confirmed exactly as the log
-- states: $10,953.50 gross, precisely -$10,953.50 net, $21,907.00
-- cancelled_value. Verified computationally against all five customers
-- named as showing "exact negative mirror" behavior: 12918, 14802
-- ($1,502.98 / -$1,502.98), 15802 ($451.42 / -$451.42), and 13290
-- ($208.63 / -$208.63) all genuinely satisfy net = -gross exactly.
-- Customer 16446 does NOT fit this pattern -- their net value is
-- -$6.10, not -$168,472.50. 16446's actual signature is different:
-- near-total cancellation (net approximately zero despite a very large
-- gross figure), not a doubling/mirror relationship.

-- CONFIRMED FINDING: The dollar-value comparison confirms a real,
-- behaviorally significant cancellation pattern. Four of the five
-- customers named as showing an "exact negative mirror" pattern
-- (12918, 14802, 15802, 13290) genuinely satisfy net = -gross exactly,
-- confirmed to the cent -- too precise to be ordinary cancellation
-- behavior, motivating the Query 57 investigation that follows.
-- Customer 16446, also grouped into that same category, does NOT
-- satisfy this pattern: their net value is -$6.10, not -$168,472.50.
-- 16446 instead shows the single largest cancelled_value in the
-- dataset by a wide margin ($168,478.60), via a different mechanism --
-- near-total cancellation, not exact doubling. This is a genuine
-- discrepancy between the stated grouping and the actual data,
-- confirmed directly from this query's own output. Flagged here as an
-- open miscategorization at this point in the investigation -- not yet
-- resolved, not yet explained, and not assumed to self-correct.