-- Query 139_customer_12607_order_history_check

-- WHAT: Pull full transaction-level detail for customer 12607 from
--       clean_transactions -- every invoice, line item, quantity, and
--       unit price -- to characterize the £1,579.51 gross / £0.00 net
--       / £1,579.51 gap (100.0% of gross -- entirely cancelled)
--       identified in Query 118's cancelled-bulk-order signature scan.
-- WHY: Query 118 flagged 7 customers matching the cancelled-bulk-order
--      signature. Customer 12607 (recency 57, frequency 1,
--      cancellation_count 1) is one of the 4 remaining uncharacterized
--      customers from that list.

SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '12607'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): exactly two invoices. 570467
-- (2011-10-10, 101 line items, £1,579.51) fully and exactly cancelled 2
-- days later by C570867 -- every stock code and quantity matches the
-- original order precisely, with no excess and no shortfall (unlike
-- customer 16077's mismatched cancellation quantity). Gross £1,579.51,
-- net £0.00, gap 100.0% -- all confirm exactly against Query 118. No
-- reorder or replacement purchase followed.

-- CONFIRMED FINDING: This is the simplest case of the four
-- uncharacterized Query 118 customers -- a single large multi-item
-- order (101 line items, likely a gift-shop or small-retailer stocking
-- order given the product mix: cake cases, doilies, party supplies,
-- ribbon, wrap) placed and then fully cancelled two days later with an
-- exact, matching cancellation record. No genuine purchase, no
-- reorder-at-different-price cycle like customer 12454, no mismatched
-- cancellation quantity like customer 16077. This customer's real net
-- contribution is genuinely zero -- consistent with a straightforward
-- change-of-mind or checkout-error cancellation rather than any of the
-- more unusual patterns seen elsewhere in this signature group.