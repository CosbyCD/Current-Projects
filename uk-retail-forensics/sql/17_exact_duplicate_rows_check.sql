-- Query 17_exact_duplicate_rows_check

-- ============================================================
-- INVESTIGATION: Exact duplicate rows — dataset-wide check
-- WHAT: Finds rows that are fully identical across every column
--       (invoice_no, stock_code, description, quantity,
--       unit_price, customer_id, invoice_date) appearing more
--       than once in the raw table.
-- WHY: Noticed in query 06's output that three invoices on
--      stock code 15044B (536525, 537405, 537434) each appeared
--      as fully identical duplicate lines. Checking whether this
--      was isolated to that one product or a broader pattern
--      across the dataset — duplicate rows would inflate
--      quantity and monetary totals in the derived fields if
--      left uncorrected.
-- ============================================================
SELECT
    invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date,
    COUNT(*) AS duplicate_count
FROM uk_retail.raw_transactions
GROUP BY invoice_no, stock_code, description, quantity, unit_price, customer_id, invoice_date
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- RESULT: Confirms this is a widespread, dataset-wide pattern, not
-- isolated to 15044B. Duplicate counts per unique row range from 2 up to
-- 20 (the highest-count row: invoice 555524, stock codes 22698/22697,
-- "PINK REGENCY TEACUP AND SAUCER" / "GREEN REGENCY TEACUP AND SAUCER",
-- customer 16923.0, appearing 20 times each as fully identical rows).
-- Duplication is heavily concentrated around a small number of specific
-- dates and invoices — most conspicuously 2010-12-05 through
-- 2010-12-12 (pre-Christmas), where a large cluster of invoices
-- (537xxx-538xxx range: 537224, 537781, 537154, 537265, 536796, 536412,
-- 537196, 537646, and many more) each contribute many duplicate line
-- items simultaneously. Duplication is not confined to positive-quantity
-- sales rows either — genuine cancellation invoices also appear
-- duplicated (e.g. C538341, three line items each duplicated at
-- duplicate_count of 3; C525550, duplicate_count of 3), confirming this
-- is a row-level data capture issue affecting the whole table uniformly,
-- not something tied to a specific transaction type. The duplication
-- also is not limited to single-item orders — large multi-line invoices
-- (e.g. 537781 with 15+ distinct line items, 536796 with a similar
-- count) show every one of their line items duplicated together,
-- suggesting whole invoices were captured or imported more than once
-- rather than individual rows being duplicated by a formula or export
-- error.

-- CONFIRMED FINDING: Exact duplicate rows are a genuine, widespread
-- dataset-wide issue, not an isolated artifact of one product (15044B)
-- as first observed in Query 06. The pattern of whole invoices being
-- duplicated together (all their line items, all sharing the same
-- duplicate_count) rather than scattered individual-row duplication
-- strongly suggests a source-side data capture or export issue —
-- entire invoices being logged, exported, or imported more than once —
-- rather than random noise. The heavy concentration around the
-- pre-Christmas period (early-mid December 2010) may reflect
-- higher-volume, higher-stress order processing during peak season,
-- though this is an observation, not yet a confirmed cause. These
-- duplicate rows must be deduplicated (collapsed to a single row per
-- unique invoice/stock_code/description/quantity/price/customer/
-- timestamp combination) before any quantity or monetary aggregation,
-- or they would inflate customer spend, order frequency, and product
-- quantity totals. See Query 18 for the summary count of how many total
-- rows and how much monetary/quantity impact this deduplication
-- represents.