-- Query 16_blank_description_1693_characterization

-- ============================================================
-- FINDING: The remaining 1,693 blank-description rows —
--          characterized as stock movement / non-sale entries
-- WHAT: Confirms the shared traits of the 1,693 rows found in
--       query 15: positive quantity, zero unit_price, no
--       customer_id, and a high concentration on non-numeric
--       administrative stock codes (POST, DOT, C2, TEST002,
--       gift_0001_XX, DCGS-prefixed codes) as well as batch-
--       timestamped entries across many ordinary product codes.
-- WHY: Query 14 found 4,382 total blank-description rows; 2,689
--      were already characterized as an undocumented negative-
--      quantity category (Phase 3). Query 15 isolated the
--      remaining 1,693. This confirms they are a distinct,
--      separate pattern: zero-price, positive-quantity,
--      no-customer entries that read as inventory/stock
--      movements rather than sales transactions.
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_price,
    COUNT(*) FILTER (WHERE quantity > 0) AS positive_qty,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS no_customer,
    COUNT(*) FILTER (WHERE stock_code !~ '^[0-9]+[A-Za-z]*$') AS non_standard_stock_code
FROM uk_retail.raw_transactions
WHERE (description IS NULL OR TRIM(description) = '')
AND NOT (quantity < 0 AND (customer_id IS NULL OR TRIM(customer_id) = ''));

-- RESULT: total = 1,693; zero_price = 1,693; positive_qty = 1,693;
-- no_customer = 1,693 — full agreement with Query 15's verification,
-- confirming all four traits hold across 100% of this category with no
-- exceptions. non_standard_stock_code = 37 — only 37 of the 1,693 rows
-- (2.2%) use a genuinely non-standard code pattern (the admin codes like
-- POST, DOT, C2, TEST002, gift_0001_XX, DCGS-prefixed codes visible in
-- Query 15's sample). The remaining 1,656 rows (97.8%) use ordinary
-- numeric or trailing-letter stock codes indistinguishable in format
-- from real product codes — meaning the vast majority of this category
-- cannot be identified by stock code pattern alone; the zero-price +
-- positive-qty + no-customer + blank-description signature together is
-- the only reliable way to isolate them.

-- CONFIRMED FINDING: The 1,693-row category is fully confirmed as a
-- distinct, internally consistent pattern (100% agreement across all
-- four defining traits), separate from the negative-qty/blank-desc
-- category in Queries 06-10. Critically, this category is NOT primarily
-- an "admin code" problem — only 2.2% of rows use recognizably
-- non-product codes. The other 97.8% sit on ordinary-looking stock
-- codes, meaning stock_code alone would never have surfaced this
-- category; it was only found by cross-referencing blank description
-- against price and customer_id together (Query 15's approach). This
-- reinforces that the exclusion logic built in Query 24 needs to key off
-- the zero-price/positive-qty/no-customer/blank-description signature
-- itself, not stock code patterns, to correctly capture all 1,693 rows.
-- Combined with Queries 06-10's 2,689-row category, this closes out the
-- full blank-description investigation from Query 14: all 4,382 blank-
-- description rows are now accounted for and characterized as one of
-- two non-customer-facing categories (2,689 negative/write-off,
-- 1,693 positive/stock-receipt), with zero unexplained blank-description
-- rows remaining.