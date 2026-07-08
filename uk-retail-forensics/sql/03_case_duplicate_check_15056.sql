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