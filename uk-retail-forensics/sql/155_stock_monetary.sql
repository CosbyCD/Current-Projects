-- Query 155_stock_monetary

-- WHAT: Third field of stock_behavior_fields: monetary_gross (revenue
--       from completed orders only) and monetary_net (revenue across
--       all orders, cancellations included), per stock_code. Mirrors
--       the customer-side both-forks precedent (Query 54-58) exactly.
-- WHY: Cancellations matter for true SKU-level revenue the same way
--      they mattered for customer spend (the gross-vs-net discovery,
--      queries 111-121) -- a SKU with a large cancelled bulk order
--      would show inflated gross revenue the same way customer 12346
--      did. Both versions built and compared per the standing
--      both-forks rule.

SELECT
    a.stock_code,
    a.monetary_gross,
    b.monetary_net
FROM (
    SELECT stock_code, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_gross
    FROM uk_retail.full_transactions
    WHERE invoice_no NOT LIKE 'C%'
    GROUP BY stock_code
) a
JOIN (
    SELECT stock_code, ROUND(SUM(quantity*unit_price)::NUMERIC,2) AS monetary_net
    FROM uk_retail.full_transactions
    GROUP BY stock_code
) b
ON a.stock_code = b.stock_code
ORDER BY a.stock_code;

-- RESULT (verified against pasted CSV): 4,721 rows, matching Query 154's
-- SKU population exactly (confirmed identical stock_code sets). Top
-- gross/net gap outlier: stock_code 23166 ("MEDIUM CERAMIC TOP STORAGE
-- JAR"), gap £77,479.64 -- this is the same stock code from customer
-- 12346's cancelled bulk order (Query 111): 74,215 units x £1.04 =
-- £77,183.60, matching all but ~£296 of the total gap, which is
-- attributable to a small number of separate, unrelated cancellations
-- of the same item by other customers. Remaining top outliers (22423,
-- 85123A, 71477, 21108, 79323W, 21843, 84078A, 23113, 48185) range
-- £4,600-£16,500 in gap -- none yet individually traced.

-- CONFIRMED FINDING: Stock-side monetary is built and verified. The
-- top outlier directly cross-confirms a Chapter Three finding
-- (customer 12346's cancelled bulk order) from an independent angle --
-- strong evidence the stock-side framework is internally consistent
-- with the customer-side one, not just separately correct. The
-- remaining 9 outliers are not individually characterized here,
-- consistent with this sprint's deliberately narrow scope -- available
-- as candidates for Phase 4's headline finding if useful, not chased
-- exhaustively the way Query 118's customer-side signature was.