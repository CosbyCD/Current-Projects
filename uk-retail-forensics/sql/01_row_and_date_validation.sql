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
