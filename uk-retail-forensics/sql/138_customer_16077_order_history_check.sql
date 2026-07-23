-- Query 138_customer_16077_order_history_check

-- WHAT: Pull full transaction-level detail for customer 16077 from
--       clean_transactions -- every invoice, line item, quantity, and
--       unit price -- to characterize the £2,300.40 gross / £600.00
--       net / £1,700.40 gap (73.9% of gross) identified in Query 118's
--       cancelled-bulk-order signature scan.
-- WHY: Query 118 flagged 7 customers matching the cancelled-bulk-order
--      signature. Customer 16077 (recency 573, frequency 1,
--      cancellation_count 1) is one of the 4 remaining uncharacterized
--      customers from that list -- this closes that gap the same way
--      Query 137 closed it for 12454.

SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '16077'
ORDER BY invoice_date, invoice_no;

-- RESULT (verified against pasted CSV): two invoices only. 502333
-- (2010-03-24, £2,300.40 gross, 8 line items) and C508455 (2010-05-14,
-- 51 days later, single line item, -£1,700.40). Gross, net, and gap all
-- confirm exactly against Query 118. HOWEVER: the cancellation covers
-- ONLY stock code 79341 ("WILLOW BRANCH LIGHTS."), and cancels -312
-- units -- 24 units MORE than the 288 units of that same stock code
-- purchased on invoice 502333. This is not a full-line cancellation; it
-- is a cancellation exceeding the recorded purchase quantity for the
-- same item by 24 units / £130.80. Quantified directly: if the
-- cancellation had exactly matched the 288-unit purchase, net would be
-- £730.80; the actual £600.00 net is exactly £130.80 lower, confirming
-- the 24-unit excess accounts for the entire discrepancy.

-- CONFIRMED FINDING: Distinct anomaly type from customers 12346 (single
-- placed-and-cancelled order), 13091 (likely duplicate cancellation
-- record), and 12454 (genuine order-cancel-reorder cycle at a lower
-- price). Here, a single cancellation record references a larger
-- quantity of a specific stock code than was ever purchased by this
-- customer on the referenced invoice. Possible explanations -- a data
-- entry/quantity error on the cancellation record, a partial return of
-- stock this customer held from a source outside this invoice (e.g. a
-- prior purchase before the dataset's start date, not captured here),
-- or a genuine bulk-order quantity correction recorded incorrectly --
-- cannot be distinguished from the data alone. FLAGGED as an open
-- data-quality item, not resolved: this is the same "cancellation
-- quantity exceeds purchase quantity" pattern worth checking for
-- elsewhere in the dataset, since it has not been systematically
-- searched for outside this one customer.