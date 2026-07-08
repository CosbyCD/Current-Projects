-- ============================================================
-- SUPPORTING CHECK: Stock code concentration in the 2,689
-- WHAT: Breaks down the 2,689 negative-qty/blank-description
--       rows by stock_code, to see if the pattern concentrates
--       on specific products or spreads across many.
-- WHY: Query 06 found this pattern on 15044B. Checking whether
--      that was a one-off product or whether this undocumented
--      category shows up broadly across many different stock
--      codes — useful context for the data quality write-up.
-- ============================================================
SELECT stock_code, COUNT(*) AS occurrences
FROM uk_retail.raw_transactions
WHERE quantity < 0
AND (description IS NULL OR TRIM(description) = '')
GROUP BY stock_code
ORDER BY occurrences DESC
LIMIT 20;