-- Query 144_customer_13206_order_history_check
-- WHAT/WHY: characterize customer 13206 (recency 399, freq 13,
-- gross £8,308.19, net £8,308.19, cancellation_count 0) from Query 141.

SELECT
    invoice_no, invoice_date, stock_code, description,
    quantity, unit_price, (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '13206'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): 566 line items across 13
-- invoices, all completed, zero cancellations. Gross and net both
-- confirm exactly at £8,308.19. Activity spans 2009-12-07 to
-- 2010-11-04 (about 11 months). Average 43.5 items per invoice,
-- ranging 2 to 83 -- notably large basket sizes for a 13-order
-- history. Product mix is small gift-shop/homeware and party-supply
-- stock (lunchboxes, candle holders, baskets, cake stands, party
-- supplies, greeting cards) -- consistent with the cohort's
-- small-retailer stocking hypothesis, with an emphasis on
-- party/celebration goods.

-- CONFIRMED FINDING: Customer 13206 is a straightforward, entirely
-- genuine buyer -- 13 real completed orders over roughly a year, zero
-- cancellations, no gross/net gap to explain. Large average basket
-- size (43.5 items/order) is consistent with a small shop stocking up
-- in substantial batches rather than one-off individual purchases.
-- The £8,308.19 figure requires no further characterization; it is
-- fully trustworthy as stated.