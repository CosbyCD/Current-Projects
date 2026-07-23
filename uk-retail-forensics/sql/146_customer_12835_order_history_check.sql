-- Query 146_customer_12835_order_history_check
-- WHAT/WHY: characterize customer 12835 (recency 417, freq 41,
-- gross £5,996.83, net £5,972.19, cancellation_count 8) from Query 141.

SELECT
    invoice_no, invoice_date, stock_code, description,
    quantity, unit_price, (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '12835'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): 625 line items across 49
-- invoices (41 completed, 8 cancelled). Gross £5,996.83, net £5,972.19,
-- gap £24.64 (0.41% of gross) -- all confirm exactly against Query 141.
-- Activity spans 2009-12-03 to 2010-10-17 (over 10 months). All 8
-- cancellations are individually tiny (£0.85 to £8.45 each), 1-2 items
-- each, scattered across the full date range with no clustering and no
-- dominant item -- consistent with routine, incidental order
-- corrections rather than any distorting event.

-- CONFIRMED FINDING: Customer 12835 is a genuine, high-frequency buyer
-- (41 completed orders in under a year -- the highest frequency of any
-- of the six customers characterized in this batch) with a negligible,
-- evenly-distributed cancellation pattern. The £5,996.83 gross figure
-- is fully trustworthy; the £24.64 gap requires no further
-- investigation.