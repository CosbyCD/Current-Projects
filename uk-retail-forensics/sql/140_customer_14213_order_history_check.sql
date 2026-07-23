-- Query 140_customer_14213_order_history_check

-- WHAT: Pull full transaction-level detail for customer 14213 from
--       clean_transactions -- every invoice, line item, quantity, and
--       unit price -- to characterize the £1,192.20 gross / £0.00 net
--       / £1,192.20 gap (100.0% of gross -- entirely cancelled)
--       identified in Query 118's cancelled-bulk-order signature scan.
-- WHY: Query 118 flagged 7 customers matching the cancelled-bulk-order
--      signature. Customer 14213 (recency 371, frequency 1,
--      cancellation_count 1) is the last of the 4 remaining
--      uncharacterized customers from that list. Note: recency 371
--      places this customer inside Query 121's own 350-399 day bucket
--      pull, which never connected it back to this flag -- this query
--      closes that specific gap too.

SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '14213'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): exactly two invoices. 529803
-- (2010-10-31, 5 line items, £1,192.20) fully and exactly cancelled 33
-- days later by C536850 -- every stock code and quantity matches
-- precisely, no excess or shortfall. Gross £1,192.20, net £0.00, gap
-- 100.0% -- all confirm exactly against Query 118. Product mix is
-- notably Christmas-seasonal: advent calendar, Christmas card holders,
-- a "Merry Christmas" doormat, Christmas lights -- the same category of
-- stock the confirmed 618-customer Nov 2010 cohort (queries 100-101)
-- bought successfully. This customer's recency (371) is confirmed to
-- fall inside Query 121's 350-399 day bucket pull; that query's
-- write-up discussed only customer 16754 and the two NULL customers
-- individually, so 14213 was present in the underlying pull but never
-- named or connected back to its Query 118 flag until now.

-- CONFIRMED FINDING: Like customer 12607, this is a straightforward
-- placed-and-cancelled order with no reorder or replacement purchase --
-- real net contribution is genuinely zero. Thematically, this customer
-- attempted the same kind of pre-Christmas seasonal stocking purchase
-- that defines the successful 618-customer Nov 2010 cohort, but
-- cancelled before it converted -- a plausible near-miss case for that
-- cohort's population, worth noting if Chapter Four ever explores
-- cancelled-attempt customers adjacent to a confirmed successful
-- cohort, though this single case alone doesn't establish a broader
-- pattern without checking whether other cancelled-only customers near
-- that seasonal window show the same product-category signature.