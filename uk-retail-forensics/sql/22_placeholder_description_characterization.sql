-- Query 22_placeholder_description_characterization

-- ============================================================
-- FOLLOW-UP: Placeholder description rows — characterization
-- WHAT: Checks whether the 327 placeholder-description rows
--       share other traits with earlier findings (zero price,
--       no customer_id, negative quantity) or are otherwise
--       normal transactions apart from the odd description.
-- WHY: Determines whether this is a new, independent category
--      or an extension of a pattern already found.
-- ============================================================
SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_price,
    COUNT(*) FILTER (WHERE quantity < 0) AS negative_qty,
    COUNT(*) FILTER (WHERE customer_id IS NULL OR TRIM(customer_id) = '') AS no_customer,
    COUNT(DISTINCT stock_code) AS distinct_stock_codes
FROM uk_retail.raw_transactions
WHERE description IN ('check', 'found', 'Check', 'Found', 'CHECK', 'FOUND', '?', 'missing', 'Missing', 'MISSING', 'lost', 'Lost', 'LOST');

-- RESULT: total = 327; zero_price = 327 (100%); no_customer = 327
-- (100%); negative_qty = 241 (73.7%); distinct_stock_codes = 286.
-- Complete overlap on two of the three traits that defined the
-- negative-qty/blank-description category from Queries 06-16 -- every
-- single placeholder-description row is also zero-price and
-- no-customer, matching that signature exactly. But quantity is NOT
-- uniformly negative: 241 rows are negative, meaning 86 rows (26.3%)
-- have positive quantity instead -- splitting this population across
-- BOTH of the two previously-identified non-customer-facing categories
-- (the 2,689-row negative/write-off group AND the 1,693-row positive/
-- stock-receipt group from Query 15), rather than sitting cleanly in
-- one or the other. The 286 distinct stock codes against 327 rows
-- confirms this is spread broadly across the catalog, not concentrated
-- on a handful of products -- consistent with Query 10's finding for
-- the negative-qty category.

-- CONFIRMED FINDING: The 327 placeholder-description rows are not a
-- new, independent category -- they are a cross-cutting subset that
-- sits inside the two non-customer-facing row types already
-- established in Queries 06-16 (zero-price, no-customer stock
-- movements), split across both the negative-quantity (write-off) and
-- positive-quantity (stock-receipt) sides depending on the specific
-- row. What's new here is not the underlying transaction category but
-- the description field itself: within these already-excluded
-- non-customer rows, description sometimes contains a genuine blank
-- (Queries 14-16) and sometimes contains operator note text like
-- "check" or "found" (this query) -- both are symptoms of the same
-- underlying non-sale, internally-adjusted transaction type, not two
-- different data problems. Practically, this means the exclusion logic
-- already being built for the zero-price/no-customer signature (Query
-- 24) will naturally capture all 327 of these rows regardless of their
-- description content -- no separate handling rule is needed for
-- placeholder text specifically, since it never occurs outside the
-- population already flagged for exclusion on other grounds.