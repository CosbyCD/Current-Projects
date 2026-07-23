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

-- RESULT (verified against pasted CSV): four completed invoices, three
-- cancellations, all confirmed exactly against Query 118's figures.
-- 527113 (£4,733.52, 8 items) cancelled in full 5 days later by C527790.
-- 527796 (£4,098.96, same 8 items and quantities, ~15% lower unit
-- prices) placed 2 minutes after that cancellation, cancelled in full
-- 21 days later by C531557. 531561 (£4,098.96, same 8 items and prices
-- as 527796) placed 3 minutes after that second cancellation -- this is
-- the ONLY invoice that survives uncancelled, and is the sole source of
-- this customer's £4,098.96 net spend. 571255 (£3,528.34, a completely
-- different 15-item product line) placed a year later, fully cancelled
-- 3 days after by C571499, with no replacement attempt. Gross, net, and
-- gap all reconcile exactly to Query 118's stated figures.

-- CONFIRMED FINDING: Unlike customer 12346 (query 111, a single
-- placed-and-cancelled bulk order with no real activity) or customer
-- 13091 (query 119, a likely duplicate-cancellation data artifact),
-- customer 12454 is a GENUINE repeat wholesale/bulk buyer who went
-- through a real order-cancel-reorder cycle: the same 8-item order was
-- attempted three times over 26 days, twice at a higher price and
-- cancelled, finally completing at a ~15%-lower negotiated price
-- (531561) -- consistent with price renegotiation rather than a data
-- artifact or an accidental duplicate. The 2011 order (571255) is a
-- separate, later, fully-cancelled attempt with no completed
-- counterpart, contributing the full remainder of the gross/net gap.
-- This customer's real net contribution (£4,098.96) is a legitimate
-- single completed wholesale order, not zero and not an artifact --
-- distinct in kind from both other characterized customers in this
-- signature group.

-- [MARKETING FLAG — added July 22, 2026: the 527113 → C527790 → 527796
-- → C531557 → 531561 sequence (same 8 items, same quantities, ~15%
-- lower unit price on the second and third attempts, all within 26
-- days) is consistent with a common e-commerce pattern: a first-time
-- visitor builds a cart, abandons at checkout, is offered a signup/
-- first-purchase discount (email capture, promo code, etc.), returns
-- and reorders at the discounted price. If so, this would mean two
-- separate abandonment events happened before the order stuck --
-- worth flagging to marketing/product as a signal, not a confirmed
-- mechanism. This dataset (clean_transactions) has NO promo-code,
-- discount-channel, marketing-source, or session/cart-abandonment
-- field, so SQL cannot confirm WHY 527796 was also cancelled before
-- 531561 finally completed -- checkout error, duplicate submission,
-- customer second-guessing, or something else. RECOMMENDATION: if
-- marketing/product has access to promo-code redemption logs, email
-- capture timestamps, or session data outside this dataset, this
-- customer_id and invoice sequence is a concrete, dateable case worth
-- cross-referencing -- it would help determine whether the second
-- cancellation reflects a genuine friction point (e.g. a checkout bug)
-- worth fixing, or is simply routine customer behavior. Not something
-- this SQL-only dataset can resolve on its own; flagged here for
-- follow-up with the appropriate team/data source rather than left
-- undocumented.]