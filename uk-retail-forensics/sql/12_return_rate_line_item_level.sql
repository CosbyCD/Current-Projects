-- Query 12_return_rate_line_item_level

-- ============================================================
-- INVESTIGATION: Return rate — line-item-level calculation
-- WHAT: Calculates return rate as proportion of a customer's
--       LINE ITEMS that were cancellations, out of their total
--       line items across all orders.
-- WHY: Second of two approaches being tested. Measures at the
--      individual product-line level rather than the whole-
--      order level, so a single cancelled item in a 10-line
--      order shows as 1/10 cancelled rather than a fully
--      cancelled order — comparing against query 11 to decide
--      which level better reflects actual customer behavior.
-- ============================================================
SELECT
    customer_id,
    COUNT(*) AS total_line_items,
    SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END) AS cancelled_line_items,
    ROUND(SUM(CASE WHEN invoice_no LIKE 'C%' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*), 4) AS line_item_return_rate
FROM uk_retail.raw_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id;

-- RESULT: One row per customer_id, line-item return rates concentrated
-- much closer to 0 than Query 11's order-level rates for the same
-- customers — e.g. customer 12346.0 shows 0.2917 here (48 line items,
-- 14 cancelled) versus 0.2941 at the order level (very close in this
-- case), but high-volume customers show a much starker gap: 14606.0 sits
-- at 0.0213 (6,709 line items, 143 cancelled) and 13089.0 at 0.0218
-- (3,438 line items, 75 cancelled) — both would show substantially
-- higher rates under the order-level method, since a single cancelled
-- line item inflates an entire multi-line order to "100% cancelled"
-- under Query 11's logic. Rates approaching or hitting 1.0000 in this
-- result are confined almost entirely to customers with very few total
-- line items (e.g. 16853.0 at 2 items, both cancelled; 15357.0, 16981.0,
-- 13463.0, 14120.0, 16151.0, 13342.0, 13231.0, 17130.0, 13910.0, each at
-- exactly 1 item, fully cancelled) — small-n customers where a single
-- event dominates the rate regardless of which method is used. The
-- blank-customer_id anomaly flagged in Query 11 does not appear in this
-- pasted sample, though this is a partial result set and its absence
-- here isn't confirmation it's fully resolved at this query.

-- CONFIRMED FINDING: Line-item-level return rate produces materially
-- different, generally lower and more granular values than order-level
-- return rate for the same customers, confirming the two methods measure
-- genuinely different things rather than being interchangeable proxies
-- for "how much does this customer return." Order-level return rate
-- answers "what fraction of this customer's shopping trips ended in some
-- return," while line-item-level answers "what fraction of everything
-- this customer ordered came back." For high-volume customers especially,
-- order-level rates are inflated by the "one bad item spoils the whole
-- order" effect, while line-item-level rates dilute a single cancellation
-- across a large denominator. Recommendation for the customer_behavior_
-- fields build: line-item-level is the more defensible default measure
-- of return behavior, since it reflects actual return VOLUME rather than
-- being dominated by order composition (how many items happened to be
-- bundled into the order containing the return). Order-level rate may
-- still be worth retaining as a secondary field if "how often does this
-- customer have a return-tainted visit" is a separately useful question
-- — a decision for whoever finalizes the customer_behavior_fields schema
-- (see Query 94).