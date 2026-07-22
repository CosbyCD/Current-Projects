-- Query 83_monetary_net_rebuild_v3

-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD (v3): Monetary Value — net
-- WHAT: Re-runs monetary_net against clean_transactions after
--       the third amendment (query 74), which excluded the
--       80,995-unit stock_code 23843 outlier (both the purchase
--       and its cancellation).
-- WHY: Since the purchase and cancellation exactly offset each
--      other, customer 16446's monetary_net should barely
--      change from the second-rebuild figure ($578,408.64 →
--      wait, that's not 16446's number, that's 18102's; 16446's
--      net was already near their gross minus that pair's net
--      contribution of ~$0). This confirms whether removing a
--      self-cancelling pair changes monetary_net at all, versus
--      monetary_gross where it mattered significantly.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_net
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary_net DESC;

-- RESULT: Top customer 18102 unchanged at $578,408.64. 5,875 rows,
-- the full current customer population. Customer 16446 confirmed at
-- exactly $2.90 -- identical to their net value at Query 69, before
-- this amendment. Removing a perfectly self-offsetting pair
-- (+$168,469.60 and -$168,469.60) from a SUM cannot change the total,
-- confirmed here directly rather than left as a mathematical
-- assumption.

-- CONFIRMED FINDING: PASSED, and confirms the exact asymmetry
-- predicted in this query's own WHY block once its mid-thought
-- correction resolves: the third amendment could only ever affect
-- monetary_gross (Query 81: $168,472.50 -> $2.90) and frequency
-- (Queries 78-80), never monetary_net, since a purchase and its exact
-- cancellation always sum to zero regardless of whether both rows are
-- present or both are removed together. Net stayed at $2.90 precisely
-- because it was already $2.90 -- this amendment simply removed two
-- rows that were mathematically inert to that particular total. See
-- Query 84 for the individual spot-check confirming this directly.