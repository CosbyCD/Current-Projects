-- Query 29_outlier_12540_qty_verification

-- ============================================================
-- FOLLOW-UP: Verify the 12,540-quantity zero-price outlier
-- WHAT: Pulls the full transaction history for stock_code 84826
--       and customer_id 13256 to see this row in context —
--       is a 12,540-unit giveaway at zero price plausible, or
--       does it look like a data entry error (e.g., misplaced
--       decimal, phantom quantity)?
-- WHY: Query 28 flagged invoice 578841 (84826, qty 12540, price
--      £0.00, customer 13256) as requiring individual
--      verification before deciding how to treat it — an
--      outlier of this size could materially distort that
--      customer's derived fields if it's a genuine error.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE (stock_code = '84826' OR customer_id = '13256')
ORDER BY invoice_date;

-- RESULT: Customer 13256.0 has exactly ONE transaction in the entire
-- dataset -- the flagged 12,540-unit row itself (invoice 578841,
-- 2011-11-25). No other order history exists for this customer to
-- compare against or corroborate. Separately, stock_code 84826's full
-- transaction history (60+ other rows spanning Dec 2009 - Dec 2011)
-- shows a clear, consistent normal order-size pattern: the overwhelming
-- majority of orders are for exactly 60 units (the product's evident
-- standard pack/case size), with smaller one-off orders of 1-32 units
-- also common, and unit_price consistently in the £0.19-£0.85 range
-- across nearly every other row (a few legitimate price changes over
-- time, but always a real, non-zero price). The 12,540-unit row is 209x
-- larger than the product's standard 60-unit case size, and zero price
-- appears on no other row for this product at all -- every other
-- instance, including bulk-looking orders, carries a real price.

-- CONFIRMED FINDING: The 12,540-unit, zero-price row for customer
-- 13256.0 is confirmed to be a genuine statistical and behavioral
-- outlier, not a plausible bulk giveaway consistent with this product's
-- normal usage pattern. Two independent signals point the same
-- direction: (1) the quantity is 209x the product's standard 60-unit
-- case size, with no other row for this product ever approaching that
-- scale, and (2) the customer has no other purchase history whatsoever
-- to establish them as a legitimate high-volume or business-account
-- customer who might plausibly receive a large promotional quantity.
-- The single-order, single-product, zero-price, extreme-quantity
-- combination is much more consistent with a data entry error (e.g., a
-- misplaced decimal, a quantity field capturing something other than
-- units, or a phantom/duplicate-key entry) than with the genuine
-- promotional-giveaway pattern established for the rest of Query 28's
-- 89-row population. RECOMMENDATION: this single row (invoice 578841)
-- should be treated as a confirmed anomaly requiring exclusion or
-- correction before customer_id 13256.0 is included in any
-- customer-behavior-field calculation -- as it stands, this one row
-- would single-handedly and falsely establish this customer as a
-- massive-volume purchaser based on a single, unverifiable, zero-price
-- transaction. This does NOT change the conclusion from Query 28 that
-- the broader 89-row zero-price/real-customer population is
-- legitimately promotional in nature -- this one row is the exception,
-- not evidence against that broader finding.