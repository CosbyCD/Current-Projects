-- Query 27_zero_price_outside_excluded_characterization

-- ============================================================
-- FOLLOW-UP: Zero-price rows outside excluded_rows — characterization
-- WHAT: Of the 1,511 zero-price rows not already in excluded_rows,
--       checks whether they have real descriptions and customer_ids
--       attached, distinguishing genuine pricing errors on real
--       transactions from another variant of internal stock activity.
-- WHY: 73,468 of the 75,359 low-price rows found in query 26 are
--      plausibly legitimate low-cost merchandise (10-49p), not a
--      data quality issue. The 1,511 exact-zero rows warrant
--      closer inspection since zero price on an otherwise real
--      transaction is a stronger anomaly signal than simply "cheap."
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE description IS NOT NULL AND TRIM(description) != '') AS has_description,
    COUNT(*) FILTER (WHERE customer_id IS NOT NULL AND TRIM(customer_id) != '') AS has_customer_id,
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_qty,
    COUNT(*) FILTER (WHERE quantity > 0) AS positive_qty
FROM uk_retail.raw_transactions r
WHERE unit_price = 0
AND NOT EXISTS (
    SELECT 1 FROM uk_retail.excluded_rows e
    WHERE e.invoice_no = r.invoice_no
    AND e.stock_code = r.stock_code
    AND e.invoice_date = r.invoice_date
);

-- RESULT: total = 1,511; has_description = 1,511 (100%); has_customer_id
-- = 89 (5.9%); negative_qty = 527 (34.9%); positive_qty = 984 (65.1%),
-- summing correctly to the full 1,511 with no zero-quantity rows. This
-- is a genuinely different signature from every prior zero-price
-- category (Queries 06-25): where Phase 3/Thread 1/Thread 3 all shared
-- blank-or-placeholder description AND no customer_id, this population
-- has a REAL description in every single row -- the defining trait that
-- separates it from everything characterized so far -- while still
-- overwhelmingly lacking a customer_id (94.1% missing). Quantity sign
-- splits both ways, unlike the earlier categories which were each
-- uniformly one direction.

-- CONFIRMED FINDING: This is a fourth, previously uncharacterized
-- zero-price category, distinct from all three found in Queries 06-23.
-- The presence of a genuine product description on every row suggests
-- these are more likely to be real stock movements involving actual,
-- identifiable products (e.g. free samples, promotional giveaways,
-- write-offs of specific damaged/lost inventory) rather than the
-- generic internal adjustments the earlier zero-price groups appear to
-- represent -- a real description implies someone was tracking a
-- specific product, not just logging a quantity change. The small
-- customer_id-present group (89 rows, 5.9%) is worth a closer look on
-- its own, since a zero-price row WITH a customer attached is the
-- closest thing yet to a genuine customer-facing anomaly (e.g. a
-- promotional freebie given to an actual customer) rather than pure
-- internal housekeeping. See Query 28 for the full detail pull on that
-- 89-row subset. This 1,511-row group is NOT folded into the existing
-- excluded_rows table under any of its three prior exclusion_reason
-- tags, since it fails the "blank/placeholder description" criterion
-- that defined membership in that table -- it remains a separately
-- tracked, uncategorized-for-exclusion population pending a decision
-- informed by Query 28's detail view.