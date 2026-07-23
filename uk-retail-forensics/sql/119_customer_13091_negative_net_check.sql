-- Query 119_customer_13091_negative_net_check
-- WHAT: Pull full transaction-level detail for customer 13091 from
--       clean_transactions -- every invoice, line item, quantity, and
--       unit price -- to characterize the anomalous negative
--       monetary_net (-£1,343.24) identified in query 118, where
--       cancellations exceed completed purchase value.
-- WHY: Query 118's full-dataset scan found 7 customers with large
--      gross/net gaps from cancelled bulk orders, but customer 13091 is
--      structurally different from the other 6 -- their monetary_net is
--      negative, meaning cancelled/returned value exceeds completed
--      purchase value. This could indicate a return of goods purchased
--      outside the dataset's date range, a data entry/unit error, or a
--      legitimate but unusual customer relationship. Needs
--      characterization before being written up, per this project's
--      standing rule.

SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '13091'
ORDER BY invoice_date, invoice_no;

-- RESULT (run July 18, 2026):
-- Customer 13091's transaction history:
--   C490807 (2009-12-08 12:25pm): large cancellation, ~36 line items,
--     covering a broad mix of gift-shop stock (mugs, purses, candles,
--     notebooks, etc.)
--   C490946 (2009-12-08 2:28pm): a SECOND large cancellation, ~2 hours
--     later the same day, covering nearly the identical stock code list
--     and quantities as C490807 -- appears to be a duplicate cancellation
--     record rather than two genuinely separate cancelled orders.
--   491193 (2009-12-10 12:44pm): a completed order two days later,
--     covering roughly HALF of the item list from the two cancellations
--     above, at matching per-unit prices but smaller scope/quantities.
--   575908 (2011-11-11): a separate, unrelated small completed order
--     over a year later.
--   C577383 (2011-11-18): a small partial cancellation of a few items
--     from the 575908 order.
--
-- CONFIRMED FINDING: Customer 13091's negative monetary_net is most
-- likely a SOURCE DATA ARTIFACT, not genuine customer return behavior --
-- invoices C490807 and C490946 appear to be a duplicated cancellation
-- record for what was originally a single cancelled order (near-identical
-- item lists, ~2 hours apart, same day), while only one partial
-- replacement order (491193, covering roughly half the item list) was
-- ever completed. This differs in kind from customers 12346 and 15749
-- (query 118), whose gross/net gaps trace to single genuine
-- cancellations. This is flagged as a candidate data-quality finding for
-- the investigation log's methodology section -- worth noting that
-- monetary_net, while more reliable than gross for the other 6 customers
-- in query 118, can itself be distorted by duplicate-cancellation entries
-- in the source data. Recommend treating 13091 as a documented known
-- exception in Chapter Four rather than excluding or correcting the
-- underlying value, consistent with this project's segregate-don't-
-- delete standard.

-- [CORRECTION — verified July 22, 2026: the RESULT block describes
-- C490807 and C490946 as having "nearly identical" item lists. Direct
-- comparison confirms they are EXACTLY identical (37/37 stock codes
-- match) — stronger evidence for the duplicate-cancellation theory than
-- originally stated. Also, invoice 491193 is described as covering
-- "roughly HALF" of the cancelled item list; actual overlap is 23/37 =
-- 62%, a majority, not half.]