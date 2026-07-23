-- Query 143_customer_14134_order_history_check
-- WHAT/WHY: characterize customer 14134 (recency 382, freq 15,
-- gross £11,123.35, net £11,123.35, cancellation_count 0 -- gross
-- equals net exactly, no cancellations at all) from Query 141.

SELECT
    invoice_no, invoice_date, stock_code, description,
    quantity, unit_price, (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '14134'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): 180 line items across 15
-- invoices, all completed, zero cancellations. Gross and net both
-- confirm exactly at £11,123.35 -- identical, as expected with zero
-- cancellation_count. Activity spans 2009-12-10 to 2010-11-22 (nearly a
-- full year). Average 12.0 items per invoice, ranging 2 to 46. Product
-- mix is small gift-shop/homeware stock (jigsaw puzzles, metal signs,
-- cake stands, drawer knobs, seasonal Christmas items, ribbon reels) --
-- consistent with the Nov 2010 cohort's small-retailer-stocking
-- hypothesis.

-- CONFIRMED FINDING: Customer 14134 is a straightforward, entirely
-- genuine buyer -- 15 real completed orders over nearly a year, zero
-- cancellations, no gross/net gap to explain. The £11,123.35 figure
-- requires no further characterization; it is fully trustworthy as
-- stated. Product mix supports the cohort's broader small-retailer
-- gift-shop stocking hypothesis.