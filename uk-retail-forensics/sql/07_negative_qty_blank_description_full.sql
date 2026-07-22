-- Query 07_negative_qty_blank_description_full

-- ============================================================
-- FINDING: Negative quantity + blank description — full list
-- WHAT: Every row where quantity is negative AND description
--       is NULL or blank/whitespace.
-- WHY: Query 06 found one example (15044B, invoice 556012)
--      with a -27 quantity row, no description, no customer_id,
--      and a zero price — distinct from a genuine 'C'-prefix
--      cancellation on the same product. This checks whether
--      that pattern was isolated or widespread across the
--      full dataset.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE quantity < 0
AND (description IS NULL OR TRIM(description) = '')
ORDER BY invoice_date;

-- RESULT: Confirms the pattern is widespread, not an isolated case —
-- hundreds of rows returned spanning nearly the entire dataset window
-- (Dec 2009 through at least May 2010 in the pasted sample). Every row
-- shares the exact structural signature identified in Query 06: negative
-- quantity, blank/NULL description, unit_price of £0.00, and no
-- customer_id. No exceptions found — not a single row in this result
-- has a populated description, a non-zero price, or a customer_id.
-- Invoice numbers are plain numeric (no "C" prefix) throughout, confirming
-- these are not cancellations. Affected stock codes span the full range
-- of the catalog (numeric-only codes, trailing-letter codes, and known
-- non-product admin-style codes like "DCGSSGIRL", "DCGS0006", "GIFT"),
-- with no concentration in any particular product family. Quantities
-- range from small (-1) to very large (-9200 on invoice 504311, -4800 on
-- two separate invoices), with no apparent pattern tying magnitude to
-- product type.

-- CONFIRMED FINDING: The structural signature identified in Query 06
-- (negative quantity + blank description + £0.00 price + no customer_id
-- + non-"C" invoice number) is confirmed as a systemic, widespread
-- pattern throughout the raw dataset, not a one-off anomaly. This
-- confirms these rows are not customer cancellations but a separate
-- category of stock/inventory adjustment entered through the same
-- table — consistent with warehouse-side corrections, write-offs, or
-- system adjustments rather than sales activity. Given the volume and
-- consistency of this pattern, these rows must be identified and
-- excluded (not merely flagged) before building customer-behavior
-- fields, or they would corrupt monetary and frequency calculations
-- with adjustments that were never real transactions. See Queries 08-10
-- for further characterization of this row category and the exclusion
-- logic built to handle it.