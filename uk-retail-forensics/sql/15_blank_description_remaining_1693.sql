-- Query 15_blank_description_remaining_1693

-- ============================================================
-- INVESTIGATION: The remaining 1,693 blank-description rows
-- WHAT: Of the 4,382 total blank-description rows found in the
--       full column completeness audit (query 14), 2,689 were
--       already characterized as negative-qty/no-customer/
--       zero-price rows (Phase 3). This isolates the remaining
--       1,693 rows that do NOT fit that pattern, to see what
--       they actually look like.
-- WHY: A genuine gap identified in query 14 — never yet
--      investigated. Could be a different pattern entirely:
--      positive quantity, a real customer_id attached, or both.
-- ============================================================
SELECT invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
FROM uk_retail.raw_transactions
WHERE (description IS NULL OR TRIM(description) = '')
AND NOT (quantity < 0 AND (customer_id IS NULL OR TRIM(customer_id) = ''))
ORDER BY invoice_date;

-- RESULT: Confirmed via aggregate verification query — all 1,693 rows in
-- this category share the exact same signature: total = 1,693,
-- positive_qty = 1,693, zero_price = 1,693, no_customer = 1,693. Every
-- single row has positive quantity (ranging from 1 up to extremes like
-- 9,600 on invoice 518241, 6,000 on 518234), unit_price of exactly
-- £0.00, and a blank/NULL customer_id — no exceptions across the full
-- population, not just the sampled rows. Stock codes span genuine
-- product codes (numeric and trailing-letter alike) as well as a
-- recurring set of non-product admin codes: "gift_0001_NN" (multiple
-- denominations, appearing repeatedly across different dates), "POST"
-- (postage), "DOT", "C2", "TEST002", and "DCGS0058". Several entries
-- show suspiciously round, large quantities (2,560 appearing six times
-- consecutively on 2010-07-16 across codes 22638-22643; 5,000-9,600
-- across codes 22752-22759 on 2010-08-05) that read as bulk stock
-- movements or system-generated entries rather than individual customer
-- purchases.

-- CONFIRMED FINDING: This is a second, distinct undocumented row
-- category, separate from the negative-qty/blank-desc pattern in
-- Queries 06-10. Where that earlier category read as inventory
-- write-offs/adjustments (negative qty, zero price, no customer, no
-- description), this category reads as inbound stock receipts or
-- internal stock movements (positive qty, zero price, no customer, no
-- description) — the mirror image in direction but the same underlying
-- signature of non-customer-facing activity entered through the
-- transaction table. The presence of "gift_0001_NN" and "POST" codes
-- also suggests this category may partially overlap with known
-- non-product admin codes already flagged elsewhere in the project
-- (see Query 58's manual-code-presence check) — worth cross-referencing
-- once that thread is reached. Like the negative-qty category, these
-- 1,693 rows must be excluded from customer-behavior-field construction,
-- since none represent real customer transactions. Full characterization
-- (exact count validation, complete breakdown of admin-code types)
-- continues in Query 16.