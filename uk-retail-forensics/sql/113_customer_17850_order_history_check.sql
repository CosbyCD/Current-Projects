-- Query 113_customer_17850_order_history_check
-- WHAT: Pull a monthly summary of order activity for customer 17850 from
--       clean_transactions -- order count and total spend per calendar
--       month -- to characterize the 155-order purchase history and the
--       shape of the drop-off leading into their 301-day dormancy,
--       identified in query 109.
-- WHY: Query 109 identified customer 17850 as a frequency outlier (301
--      days recency, 155 completed orders, £51,208.87 monetary_gross),
--      distinct from the monetary outlier (customer 12346). A high-
--      frequency, high-value customer going dormant is a meaningfully
--      different story than a low-frequency, high-ticket buyer -- worth
--      confirming whether this reads as a steady, established buyer who
--      simply stopped, or a front-loaded burst of activity that was
--      never sustained.

SELECT
    DATE_TRUNC('month', invoice_date) AS order_month,
    COUNT(DISTINCT invoice_no) AS orders_this_month,
    SUM(quantity * unit_price) AS monetary_this_month
FROM uk_retail.clean_transactions
WHERE customer_id = '17850'
GROUP BY DATE_TRUNC('month', invoice_date)
ORDER BY order_month;

-- RESULT (run July 18, 2026):
-- Monthly order activity for customer 17850:
--   2009-12: 15 orders, £7,411.14
--   2010-01: 18 orders, £8,069.04
--   2010-02: 3 orders, £1,510.06
--   2010-03: 6 orders, £2,429.44
--   2010-04: 19 orders, £7,050.72
--   2010-05: 1 order, -£330.75 (cancellation-only)
--   2010-06: 1 order, -£305.20 (cancellation-only)
--   2010-07: 20 orders, £9,595.65
--   2010-08: 1 order, -£77.42 (cancellation-only)
--   2010-09: 40 orders, £9,751.61 (peak month)
--   2010-12: 34 orders, £5,391.21 (second-largest month)
--   2011-02: 1 order, -£87.73 (cancellation-only, final activity)
-- Real order activity spans 14+ months (Dec 2009 - Feb 2011), with
-- consistent moderate-to-high monthly volume, not a single front-loaded
-- burst. December 2010 shows a stocking-pattern spike similar in timing
-- to the confirmed 618-customer Nov 2010 cohort (queries 100-101), though
-- in a completely different customer segment (high-frequency vs. that
-- cohort's low-frequency profile). Final recorded activity is a small
-- cancellation in February 2011, after which the customer goes dormant
-- (301 days recency as of the dataset's reference date).
--
-- CONFIRMED FINDING: Unlike customer 12346 (query 111), customer 17850's
-- £51,208.87 monetary_gross is credible, genuine spend -- no single bulk-
-- order/cancellation pair distorts the total; monthly figures are
-- consistent with sustained, repeated ordering at plausible per-order
-- values across 14+ months. This customer is a legitimate "lapsed
-- high-value customer" -- a real counterexample to the "no lapsed
-- whales" claim Chapter Three's chart rotation originally suggested, and
-- distinct in kind from the gross/net artifact pattern found in 12346.