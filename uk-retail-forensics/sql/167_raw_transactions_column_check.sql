-- Query 167_raw_transactions_column_check

-- WHAT: Lists the actual column names in raw_transactions, since the
--       prior query's assumption (snake_case column names matching
--       clean_transactions) was wrong.
-- WHY: Query 166 failed with "column stock_code does not exist" --
--      raw_transactions likely retains the original source CSV column
--      naming rather than the renamed columns established during the
--      cleaning pipeline (queries 00a/00b).

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'uk_retail' AND table_name = 'raw_transactions'
ORDER BY ordinal_position;