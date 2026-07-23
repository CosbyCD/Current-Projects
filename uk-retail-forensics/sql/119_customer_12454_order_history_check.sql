-- Query 137_customer_12454_order_history_check

-- WHAT: Pull full transaction-level detail for customer 12454 from
--       clean_transactions -- every invoice, line item, quantity, and
--       unit price -- to characterize the £16,459.78 gross / £4,098.96
--       net / £12,360.82 gap (75.1% of gross) identified in Query 118's
--       cancelled-bulk-order signature scan.
-- WHY: Query 118 flagged 7 customers matching the cancelled-bulk-order
--      signature (low frequency, large gross/net gap). Only 3 of the 7
--      (12346, 15749, 13091) were ever individually characterized.
--      Customer 12454 (recency 52, frequency 4, cancellation_count 3)
--      is one of the remaining 4 -- this closes that gap the same way
--      Query 111 closed it for 12346.

SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '12454'
ORDER BY invoice_date, invoice_no;