-- Query 58_manual_code_presence_check

-- ============================================================
-- FOLLOW-UP: Confirm scope — administrative stock codes still
--            present in clean_transactions
-- WHAT: Checks whether "M" (Manual) and other non-numeric
--       administrative stock codes are still present in
--       clean_transactions, contaminating customer-level
--       calculations like monetary value.
-- WHY: Query 57 found customer 12918's negative monetary_net is
--      caused entirely by three "Manual" (stock_code = 'M')
--      administrative entries, not real customer purchases.
--      Confirming whether this is isolated to a few customers
--      or a broader gap in the Chapter One exclusion logic.
-- ============================================================
SELECT stock_code, COUNT(*) AS occurrences,
       ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS total_value
FROM uk_retail.clean_transactions
WHERE stock_code !~ '^[0-9]+[A-Za-z]*$'
GROUP BY stock_code
ORDER BY occurrences DESC;

-- RESULT: 42 distinct non-numeric stock codes, 5,918 total rows,
-- confirmed present in clean_transactions. Top figures match the log
-- exactly: POST (2,079 rows, $110,430.41), DOT (1,423 rows,
-- $309,844.10), M (1,392 rows, -$83,311.28), AMAZONFEE (36 rows,
-- -$221,520.50). Net sum across all 42 codes is -$70,716.37, but the
-- sum of absolute values (total dollar activity, regardless of
-- direction) is $958,821.39 -- consistent with the log's "hundreds of
-- thousands of dollars" characterization when read as gross activity
-- rather than net impact, worth distinguishing precisely since the two
-- framings differ by an order of magnitude in sign but not scale.
-- Notable outlier not called out in the log's own summary: stock_code
-- "B" carries -$147,614.08 across only 6 rows -- the single largest
-- per-row dollar concentration in this entire list, worth its own
-- targeted look the same way "M" got one via customer 12918. Also
-- present again here: "47503J " (trailing space), the same false
-- positive already resolved back in Query 20 -- confirmed as a real
-- product ("SET/3 FLORAL GARDEN TOOLS IN BAG") with a stray whitespace
-- character, not a genuine administrative code; its $16.13 value is
-- immaterial to the totals either way but shouldn't be miscounted as
-- administrative contamination in any downstream summary.

-- CONFIRMED FINDING: Confirmed at scale -- clean_transactions, the
-- table declared complete and independently verified at the end of
-- Chapter One, still contains substantial administrative/non-product
-- activity: 42 distinct codes, 5,918 rows, nearly a million dollars in
-- gross transaction value. This is a genuine gap in the Chapter One
-- exclusion logic, not an isolated case specific to customer 12918 --
-- the pattern first characterized descriptively in Chapter One
-- (Queries 19-23) was never actually converted into an exclusion rule
-- applied to clean_transactions itself. This motivates amending
-- clean_transactions with a stock-code-pattern exclusion, which will
-- require every field already built in this chapter (Recency,
-- Frequency, Monetary Value) to be rebuilt and re-verified against the
-- amended table.