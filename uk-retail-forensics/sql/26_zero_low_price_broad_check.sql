-- Query 26_zero_low_price_broad_check

-- ============================================================
-- INVESTIGATION: Zero/unusually low unit_price rows — broad check
-- WHAT: Checks the full raw_transactions table for zero or very
--       low unit_price values, excluding rows already captured
--       and tagged in excluded_rows, to see if a distinct,
--       uncharacterized pattern exists among rows that DO have
--       a real description and/or customer_id.
-- WHY: All prior zero-price findings (Phase 3, Thread 1, Thread
--      3) were tied to blank or placeholder descriptions and no
--      customer_id. This checks whether zero/low price shows up
--      independently of those patterns — i.e., a real-looking
--      transaction (has description, has customer) with a
--      suspiciously low or zero price.
-- ============================================================
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE unit_price = 0) AS zero_price,
    COUNT(*) FILTER (WHERE unit_price > 0 AND unit_price < 0.10) AS under_10p,
    COUNT(*) FILTER (WHERE unit_price >= 0.10 AND unit_price < 0.50) AS ten_to_49p
FROM uk_retail.raw_transactions r
WHERE NOT EXISTS (
    SELECT 1 FROM uk_retail.excluded_rows e
    WHERE e.invoice_no = r.invoice_no
    AND e.stock_code = r.stock_code
    AND e.invoice_date = r.invoice_date
)
AND unit_price < 0.50;

-- RESULT: total_rows = 75,359; zero_price = 1,511; under_10p = 375;
-- ten_to_49p = 73,468. The three price buckets sum to only 75,354 --
-- 5 rows short of the reported total. Since the buckets (=0, >0 and
-- <0.10, >=0.10 and <0.50) are mathematically exhaustive for any value
-- strictly less than 0.50 and greater than or equal to 0, the only
-- explanation for 5 unaccounted rows is a NEGATIVE unit_price value --
-- a genuinely new anomaly this query wasn't designed to check for,
-- surfaced only because the bucket totals didn't reconcile against the
-- overall count. Separately, and expected: the vast majority of this
-- non-excluded low-price population (73,468 of 75,359, ~97.5%) sits in
-- the 10-49p range, which plausibly reflects real low-cost items
-- (ribbons, tags, small craft supplies) rather than data errors --
-- unlike the zero-price population, which given Queries 06-25's
-- findings warrants more scrutiny even outside the already-excluded set.

-- CONFIRMED FINDING: Two things confirmed. First, this query's original
-- question -- does a distinct, uncharacterized low-price pattern exist
-- independent of the already-excluded zero-price/no-customer rows -- is
-- confirmed YES: 1,511 zero-price rows exist OUTSIDE the excluded_rows
-- population, meaning these have either a real description, a real
-- customer_id, or both, unlike every zero-price row characterized so
-- far. These are fully characterized in Query 27 (1,511 rows: 100% have
-- a real description, only 5.9% have a customer_id, quantity splits
-- both directions) and further isolated in Query 28 (the 89-row subset
-- with a customer_id attached, pulled in full detail as the rows most
-- likely to represent a genuine customer-facing anomaly rather than
-- internal housekeeping). Second, and unplanned: the bucket arithmetic
-- gap (5 rows) surfaced the existence of negative unit_price values in
-- the dataset -- not yet characterized at all as of this query, and not
-- something any prior query in this project had checked for. Status:
-- as of this retrofit pass, no later query number in this project's
-- existing sequence (through the queries reviewed so far) has directly
-- picked up the negative-unit_price thread -- flagged as a genuine open
-- item, candidate for a dedicated follow-up query or for the
-- "Additional Avenues" documentation section if not pursued further
-- within the current sprint.