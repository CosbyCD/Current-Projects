-- Query 158_stock_return_rate

-- WHAT: Sixth and final individual field of stock_behavior_fields:
--       order_return_rate_pct (% of this SKU's distinct invoices that
--       are cancellations) and line_item_return_rate_pct (% of this
--       SKU's individual line items that are cancellations). Mirrors
--       the customer-side return rate build exactly (Query 91-93),
--       both order-level and line-item-level versions per the standing
--       both-forks rule.
-- WHY: Sourced from full_transactions, not clean_transactions -- unlike
--      demand breadth (Query 157), return rate doesn't depend on
--      customer identity at all, so it belongs with the other
--      customer-independent fields (recency, frequency, monetary,
--      interval) and benefits from the full transaction pool the same
--      way they do. A high SKU-level return rate is a quality/fit/
--      description-mismatch signal distinct from low demand -- a SKU
--      that sells often but gets returned often is a different problem
--      than a SKU that simply doesn't sell.

SELECT
    a.stock_code,
    a.order_return_rate_pct,
    b.line_item_return_rate_pct
FROM (
    SELECT stock_code,
        ROUND(100.0*COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%')/COUNT(DISTINCT invoice_no),1) AS order_return_rate_pct
    FROM uk_retail.full_transactions
    GROUP BY stock_code
) a
JOIN (
    SELECT stock_code,
        ROUND(100.0*COUNT(*) FILTER (WHERE invoice_no LIKE 'C%')/COUNT(*),1) AS line_item_return_rate_pct
    FROM uk_retail.full_transactions
    GROUP BY stock_code
) b
ON a.stock_code = b.stock_code
ORDER BY a.stock_code;

-- RESULT (verified against pasted CSV): 4,734 rows -- the full Query
-- 153 population, no exclusions, exactly as expected since neither
-- subquery filters on invoice_no NOT LIKE 'C%'. All 13 SKUs previously
-- excluded from Query 154/155 (cancellation-only, no completed orders)
-- confirmed showing exactly 100.0% on both order_return_rate_pct and
-- line_item_return_rate_pct -- a clean mechanical consistency check
-- that directly explains why those 13 SKUs had no completed-order
-- activity to measure frequency or monetary against.

-- CONFIRMED FINDING: Stock-side return rate is built and verified for
-- the full 4,734-SKU population. All six individual fields (recency,
-- frequency, monetary, interval, demand breadth, return rate) are now
-- complete. Ready to assemble stock_behavior_fields (Query 159).