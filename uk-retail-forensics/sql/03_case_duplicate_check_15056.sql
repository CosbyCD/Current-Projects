-- Query 03_case_duplicate_check_15056

-- ============================================================
-- FINDING: Stock code casing inconsistency — spot check
-- WHAT: Compares 15056BL vs 15056bl directly — same numeric
--       part, different letter casing.
-- WHY: Spotted while scrolling that the same product code
--      appeared with inconsistent casing. Checking whether
--      description/price match confirms it's the same
--      product entered inconsistently, not two products.
-- ============================================================
SELECT stock_code, description, unit_price, COUNT(*) AS occurrences,
       MIN(invoice_date) AS first_seen, MAX(invoice_date) AS last_seen
FROM uk_retail.raw_transactions
WHERE stock_code IN ('15056BL', '15056bl')
GROUP BY stock_code, description, unit_price
ORDER BY stock_code;

-- RESULT: Both casings share the identical description ("EDWARDIAN
-- PARASOL BLACK") across every row, confirming they are the same
-- physical product, not two different products. However, unit_price
-- varies substantially across BOTH casings independently — 15056bl
-- appears at 3 price points (£12.46, £12.72, £13.00), and 15056BL
-- appears at 8 price points (£0.00, £1.95, £3.00, £4.25, £4.60, £4.95,
-- £5.95, £12.46, £12.72, £13.00) — including one £0.00 row with a blank
-- description, and one row overlapping exactly with 15056bl's £12.46
-- price point. 15056BL also carries the overwhelming majority of total
-- occurrences (924 of 927 combined rows), with 15056bl as the minority
-- casing (93 rows). Date ranges for both casings span nearly the entire
-- dataset window (Dec 2009 - Dec 2011), so this is not a case of one
-- casing being used early and the other later (e.g. a mid-project fix) —
-- both casings were used concurrently throughout.

-- CONFIRMED FINDING: 15056BL and 15056bl are confirmed the same physical
-- product (identical description in every row) entered under two
-- inconsistent casings, used concurrently rather than one casing
-- replacing the other over time. This is a genuine data-entry
-- inconsistency, not a two-product situation. Separately and worth
-- flagging: the wide unit_price spread within EACH casing (11 distinct
-- price points combined, ranging £0.00-£13.00 for what should be one
-- consistently-priced product) is itself a finding independent of the
-- casing issue — this may reflect discounting, promotional pricing, or
-- data-entry price errors, and is a candidate for its own follow-up
-- query before this product's pricing is trusted anywhere downstream.
-- The £0.00/blank-description row in particular is consistent with the
-- broader zero-price pattern this project investigates in Queries 26-28.