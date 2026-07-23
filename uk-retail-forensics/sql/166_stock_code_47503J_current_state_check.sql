-- Query 166_stock_code_47503J_current_state_check

-- WHAT: Pulls all raw_transactions rows for stock_code '47503J' (with
--       and without trailing whitespace, checked separately) to
--       confirm whether they currently appear in clean_transactions or
--       are being silently excluded, and to characterize how many rows
--       and what value is actually affected.
-- WHY: Flagged as an open gap since the original handoff: Query 20
--      resolved '47503J ' (trailing space) as a genuine product, not
--      an administrative code false positive -- but Query 59's later
--      admin-code exclusion amendment re-caught it, and none of the
--      three subsequent clean_transactions amendments corrected the
--      regression. Before deciding whether this needs a formal fourth
--      amendment or can be documented as an accepted small gap, this
--      establishes the actual current state and scope.

SELECT
    stock_code,
    LENGTH(stock_code) AS code_length,
    description,
    COUNT(*) AS row_count,
    SUM(quantity * unit_price) AS total_value,
    MIN(invoice_date) AS earliest,
    MAX(invoice_date) AS latest
FROM uk_retail.raw_transactions
WHERE T

-- RESULT: Query failed before execution -- ERROR: column "stock_code"
-- does not exist, SQL state 42703. The query itself was also
-- incomplete (truncated mid-WHERE-clause, "WHERE T" with no closing
-- condition) -- an assistant-side generation error, not a genuine
-- schema mismatch. Query 167 confirmed raw_transactions does in fact
-- have a stock_code column identical to clean_transactions' naming;
-- the reported column error was likely a side effect of the truncated,
-- syntactically invalid WHERE clause rather than a real absent-column
-- issue. Superseded by the corrected, complete version at Query 168.

-- CONFIRMED FINDING: N/A -- this query never executed successfully.
-- Preserved per this project's segregate-don't-delete standard as a
-- documented false start rather than removed from the record. See
-- Query 168 for the working version and its actual results.