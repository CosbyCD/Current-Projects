-- Query 158_stock_return_rate corrected

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

-- [FLAGGED] This query was run against full_transactions before the
-- double-counting bug (confirmed and fixed at Queries 151b/151c/151d)
-- was corrected -- and this query is a mixed case, unlike any prior
-- field in this chapter. order_return_rate_pct uses
-- COUNT(DISTINCT invoice_no), duplicate-insensitive for the same reason
-- Queries 154/156 were confirmed safe. line_item_return_rate_pct uses
-- raw COUNT(*) in both numerator and denominator -- NOT
-- duplicate-insensitive. Being a ratio doesn't make it automatically
-- safe: it only stays correct if duplicated rows split proportionally
-- between cancelled and completed for every SKU, which has no
-- structural guarantee across 4,734 SKUs. order_return_rate_pct is
-- reasoned safe; line_item_return_rate_pct is NOT reasoned safe and
-- requires an actual rerun against the corrected full_transactions and
-- a full diff before this RESULT can be treated as final.

-- [REVISION -- confirmed via rerun and full diff against corrected
-- full_transactions] Rerunning this exact query against the corrected
-- table and diffing both columns separately confirmed the mixed-case
-- hypothesis exactly. order_return_rate_pct: ZERO differences across
-- all 4,734 SKUs -- fully confirmed duplicate-insensitive, matching
-- Queries 154 and 156. line_item_return_rate_pct: 2,540 of 4,734 SKUs
-- (54%) show real differences -- NOT duplicate-insensitive, as flagged.
-- Direction is predominantly one-way: 2,415 of the 2,540 changed SKUs
-- show a HIGHER corrected rate than the buggy figure, 125 show lower.
-- This is consistent with unattributed transactions skewing toward
-- completed (non-cancelled) activity for most SKUs -- their duplication
-- diluted the buggy return rate downward, and correcting the duplicate
-- inflated the denominator's non-cancelled weight back down, raising the
-- rate for most affected SKUs. The 125 SKUs moving the opposite
-- direction reflect per-SKU variation in what proportion of THEIR
-- specific duplicated unattributed rows were cancellations -- not an
-- inconsistency in the fix, just normal per-item variation. The
-- original CONFIRMED FINDING above (return rate "built and verified")
-- is superseded for line_item_return_rate_pct specifically:
-- order_return_rate_pct's original values stand unchanged;
-- line_item_return_rate_pct's original values are superseded by the
-- corrected rerun and should not be cited going forward.