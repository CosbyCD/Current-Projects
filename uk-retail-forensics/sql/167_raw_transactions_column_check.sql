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
-- RESULT: 8 columns returned -- invoice_no, stock_code, description,
-- quantity, invoice_date, unit_price, customer_id, country -- exactly
-- matching clean_transactions' naming convention (snake_case,
-- identical column names). No original-source-CSV naming variant
-- exists in raw_transactions.

-- CONFIRMED FINDING: The hypothesis in this query's own WHY block was
-- wrong -- raw_transactions does NOT retain different original column
-- naming from the cleaning pipeline. stock_code exists in
-- raw_transactions with the identical name Query 166 used. This
-- confirms Query 166's actual failure cause was its truncated,
-- syntactically invalid WHERE clause ("WHERE T", cut off mid-condition)
-- -- a genuine SQL syntax error, not a column-naming mismatch. No
-- further schema investigation needed; Query 168 (or the reconstruction
-- now standing in for Query 166) can reference stock_code directly.