-- Query 142_customer_13564_order_history_check
-- WHAT/WHY: characterize customer 13564 (recency 353, freq 36,
-- gross £15,880.22, net £15,613.10, cancellation_count 13) from the
-- Nov 2010 cohort's genuine £5,000+ tail (Query 141).

SELECT
    invoice_no, invoice_date, stock_code, description,
    quantity, unit_price, (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '13564'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): 1,237 line items across 49
-- invoices (36 completed, 13 cancelled). Gross £15,880.22, net
-- £15,613.10, gap £267.12 (1.68% of gross) -- all confirm exactly
-- against Query 141. Activity spans 2009-12-02 to 2010-12-20 (over a
-- year). Average 25.2 items per invoice, ranging 1 to 92. The gap is
-- distributed across 13 separate small cancellations, not concentrated
-- in one event -- the largest single cancellation is only £46.75.

-- CONFIRMED FINDING: Customer 13564 is a genuine, sustained
-- high-volume buyer, not an artifact of any kind -- large, frequent
-- orders over more than a year, with a small, evenly-distributed
-- cancellation rate (1.68% of gross) consistent with ordinary
-- day-to-day order corrections rather than any single distorting event.
-- This is the strongest "real spend" case of the six remaining
-- customers so far, and confirms the £15,880.22 gross figure is a
-- trustworthy representation of this customer's actual value.