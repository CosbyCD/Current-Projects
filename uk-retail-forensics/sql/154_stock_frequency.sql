-- Query 154_stock_frequency

-- WHAT: Second field of stock_behavior_fields: frequency_completed
--       (distinct completed orders containing this SKU) and
--       frequency_all (distinct orders of any kind), following the
--       customer-side both-forks precedent (Query 50-53) rather than
--       picking one definition in advance.
-- WHY: Mirrors the customer-side frequency build exactly -- completed-
--      only reflects genuine demand, all-orders reflects total order
--      touch including cancelled attempts. Both are built and compared
--      per this project's standing both-forks rule.

SELECT
    a.stock_code,
    a.frequency_completed,
    b.frequency_all,
    (b.frequency_all - a.frequency_completed) AS cancellation_count
FROM (
    SELECT stock_code, COUNT(DISTINCT invoice_no) AS frequency_completed
    FROM uk_retail.full_transactions
    WHERE invoice_no NOT LIKE 'C%'
    GROUP BY stock_code
) a
JOIN (
    SELECT stock_code, COUNT(DISTINCT invoice_no) AS frequency_all
    FROM uk_retail.full_transactions
    GROUP BY stock_code
) b
ON a.stock_code = b.stock_code
ORDER BY a.stock_code;

-- RESULT (verified against pasted CSV): 4,721 rows, NOT 4,734 (Query
-- 153's SKU count). The 13-SKU gap is structural, not an error: these
-- 13 stock codes (20779, 21053, 21254, 21315, 21346, 21766, 22003,
-- 35001C, 35631B, 47567, 79340P, 79340W, 85219) appear only on cancelled
-- invoices -- zero completed orders -- so they have no row in the
-- frequency_completed subquery and are dropped by the INNER JOIN. This
-- is the SKU-level structural equivalent of the customer side's 23
-- never-converted customers.

-- CONFIRMED FINDING: Stock-side frequency is built and verified for
-- 4,721 SKUs with at least one completed order. The 13 cancellation-
-- only SKUs are a legitimate, small population requiring their own
-- treatment when stock_behavior_fields is assembled (Query 159-160) --
-- either a LEFT JOIN preserving them with NULL frequency values
-- (matching the customer-side pattern) or an explicit "never sold"
-- flag, decided at assembly time.