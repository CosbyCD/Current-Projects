-- Query 28_zero_price_with_customer_id_detail

-- ============================================================
-- FOLLOW-UP: Zero-price rows WITH a customer_id — closest look
-- WHAT: Isolates the 89 rows that are zero-price, have a real
--       description, AND have a customer_id attached — these
--       are the only zero-price rows in this thread that would
--       directly affect a real customer's derived fields.
-- WHY: Of 1,511 zero-price rows outside excluded_rows, 1,422
--      have no customer_id (same unattributed pattern as
--      excluded_rows) and can reasonably be treated the same
--      way. The 89 WITH a customer_id are different — a zero
--      price on an attributed transaction could mean a
--      promotional/free item, a pricing error, or something
--      else worth seeing directly before deciding how to
--      handle it in the clean table.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions r
WHERE unit_price = 0
AND customer_id IS NOT NULL AND TRIM(customer_id) != ''
AND NOT EXISTS (
    SELECT 1 FROM uk_retail.excluded_rows e
    WHERE e.invoice_no = r.invoice_no
    AND e.stock_code = r.stock_code
    AND e.invoice_date = r.invoice_date
)
ORDER BY invoice_date;

-- RESULT: 89 rows (matching Query 27's count exactly). Every row is
-- attached to a real customer_id and carries a genuine, specific
-- product description -- no blank descriptions, no placeholder text,
-- no admin-style stock codes dominating (though a handful of known
-- admin codes do appear: "M"/"Manual" x8, "PADS" x15, "TEST001" x2,
-- "BANK CHARGES" x1 -- 26 of 89 rows, ~29%). The remaining ~71% (63
-- rows) are ordinary numeric product codes with real product names
-- (e.g. "6 RIBBONS EMPIRE", "REGENCY CAKESTAND 3 TIER", "RED KITCHEN
-- SCALES") at zero price -- these read as genuine promotional/free-item
-- giveaways to real customers, not data entry errors. One extreme
-- outlier: invoice 578841, stock_code 84826 ("ASSTD DESIGN 3D PAPER
-- STICKERS"), customer 13256.0, quantity 12,540 at zero price on
-- 2011-11-25 -- a single free-item quantity two to three orders of
-- magnitude larger than every other row in this set (next-largest
-- quantities are in the low hundreds: 648, 240, 216, 192, 144). Also
-- noted: invoice 537197 appears twice as an identical duplicate row
-- (stock_code 22841, same quantity/customer/timestamp) -- consistent
-- with the exact-duplicate pattern already characterized dataset-wide
-- in Queries 17-18, confirming this row falls into that category too.

-- CONFIRMED FINDING: The 89 zero-price/real-customer rows are
-- overwhelmingly genuine promotional or free-item transactions given to
-- real, identifiable customers -- not internal housekeeping and not
-- data entry errors in the general case. "PADS," "M" (Manual), and
-- similar admin-style codes account for a real but minority share
-- (~29%); the majority are ordinary products given away at zero cost.
-- This is a materially different category from everything in
-- excluded_rows and should NOT be swept into that table -- these rows
-- represent real customer relationship activity (goodwill items,
-- promotional freebies) that arguably belongs in customer-behavior
-- calculations, just correctly reflected as zero monetary value rather
-- than excluded from frequency/order counts entirely. The customer_id
-- 13256.0 outlier (12,540-unit stickers giveaway) is large enough to
-- warrant an individual verification pass on that specific customer
-- before trusting any aggregate field involving quantity for them (see
-- Query 29, which appears to be built for exactly this check). Also
-- confirmed: at least one row in this set (invoice 537197) independently
-- reproduces the exact-duplicate pattern from Queries 17-18, meaning
-- this population is not fully independent of that earlier
-- deduplication issue and should be checked against it before final
-- customer-field construction.