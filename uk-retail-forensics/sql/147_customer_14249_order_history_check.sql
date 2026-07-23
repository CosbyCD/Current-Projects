-- Query 147_customer_14249_order_history_check
-- WHAT/WHY: characterize customer 14249 (recency 410, freq 12,
-- gross £5,400.46, net £5,400.46, cancellation_count 0) from Query 141.

SELECT
    invoice_no, invoice_date, stock_code, description,
    quantity, unit_price, (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '14249'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): 271 line items across 12
-- invoices, all completed, zero cancellations. Gross and net both
-- confirm exactly at £5,400.46. Activity spans 2010-01-29 to
-- 2010-10-25 (about 9 months). Average 22.6 items per invoice, ranging
-- 1 to 79. Product mix is small gift-shop/homeware and seasonal stock
-- (parasols, cushion covers, cake stands, cake cases, garden decor,
-- gift wrap) -- consistent with the cohort's small-retailer stocking
-- hypothesis.

-- CONFIRMED FINDING: Customer 14249 is a straightforward, entirely
-- genuine buyer -- 12 real completed orders over roughly 9 months,
-- zero cancellations, no gross/net gap to explain. The £5,400.46
-- figure requires no further characterization; it is fully trustworthy
-- as stated.