-- Query 01_row_and_date_validation

-- ============================================================
-- VALIDATION: Row count and date range
-- WHAT: Confirms the imported table matches the documented
--       dataset size and time span before any analysis begins.
-- WHY: If the import didn't land correctly, everything built
--      after this point would be built on bad data.
-- ============================================================
SELECT COUNT(*) AS total_rows FROM uk_retail.raw_transactions;
SELECT MIN(invoice_date) AS earliest_date,
       MAX(invoice_date) AS latest_date
FROM uk_retail.raw_transactions;

-- RESULT: total_rows = 1,067,371. Date range: earliest_date =
-- 2009-12-01 07:45:00, latest_date = 2011-12-09 12:50:00.

-- CONFIRMED FINDING: The imported table matches the documented dataset
-- size and time span exactly — 1,067,371 rows spanning December 2009
-- through December 2011, confirming the import landed correctly before
-- any cleaning or analysis work began.