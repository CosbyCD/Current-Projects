-- Query 93_return_rate_comparison_v2

-- ============================================================
-- CHAPTER TWO, FIELD 6: Return Rate — comparison (rebuild)
-- WHAT: Joins the rebuilt order-level (query 91) and line-item-
--       level (query 92) return rates into one result, with the
--       percentage-point gap between them per customer.
-- WHY: Same both-sides comparison practice applied throughout
--      this chapter. The gap shows which customers' return
--      rate picture changes most depending on which
--      granularity is used to measure it.
-- ============================================================
SELECT
    a.customer_id,
    a.order_return_rate_pct,
    b.line_item_return_rate_pct,
    ROUND(a.order_return_rate_pct - b.line_item_return_rate_pct, 1) AS rate_gap_pct
FROM (
    SELECT customer_id,
           ROUND(100.0 * COUNT(DISTINCT invoice_no) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(DISTINCT invoice_no), 1) AS order_return_rate_pct
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) a
JOIN (
    SELECT customer_id,
           ROUND(100.0 * COUNT(*) FILTER (WHERE invoice_no LIKE 'C%') / COUNT(*), 1) AS line_item_return_rate_pct
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) b ON a.customer_id = b.customer_id
ORDER BY ABS(a.order_return_rate_pct - b.line_item_return_rate_pct) DESC;

-- RESULT: 5,875 rows -- the full population, with zero customers
-- dropped by the join. Unlike the frequency comparison (Query 52) and
-- monetary comparison (Query 56), where an inner join between a
-- completed-only subquery and a full-population subquery silently
-- excluded customers with zero completed activity, both subqueries
-- here (a and b) cover the identical full 5,875-customer population
-- with no completed-only filter on either side -- meaning the plain
-- JOIN is safe by construction and produces no coverage gap. Top gaps
-- are substantial: customer 12590 shows a 69.4 percentage-point
-- difference (75.0% order-level vs. 5.6% line-item-level), the same
-- "small cancelled order among large regular orders" pattern already
-- characterized in Chapter One (Query 13).

-- CONFIRMED FINDING: The return rate comparison is rebuilt correctly
-- and, notably, does not repeat the join-coverage issue that affected
-- the frequency and monetary value comparisons earlier in this
-- chapter -- worth flagging as a positive contrast: the same "both-
-- sides" comparison pattern can be join-safe or join-unsafe depending
-- on whether the two sides share an identical population, and here
-- they do. This completes Field 6 (Return Rate)'s rebuild in full.
-- All six core customer behavior fields (Recency, Frequency, Monetary
-- Value, Interval, Product Diversity, Return Rate) are now built,
-- verified, and ready to be joined into one final table.