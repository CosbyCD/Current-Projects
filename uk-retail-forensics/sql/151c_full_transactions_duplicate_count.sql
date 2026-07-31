-- Query 151c_full_transactions_duplicate_count

-- WHAT: Counts every TRUE-labeled row in full_transactions that has a
-- matching invoice_no/stock_code/invoice_date/quantity row in
-- unattributed_transactions -- quantifying the full scope of the
-- duplication pattern confirmed at Query 151b, rather than relying on
-- that query's 20-row sample.
-- WHY: Query 151b confirmed the duplication pattern exists but was
-- capped at LIMIT 20. Before rebuilding full_transactions or assessing
-- downstream impact on stock_behavior_fields and Chapter Five's headline
-- findings, the actual scope needs a real count -- either the bug is
-- systematic (affecting all 228,297 unattributed rows) or partial
-- (affecting only some subset), and that distinction changes how serious
-- the downstream impact is.

SELECT COUNT(*) AS affected_rows
FROM uk_retail.full_transactions f
WHERE EXISTS (
    SELECT 1 FROM uk_retail.unattributed_transactions u
    WHERE u.invoice_no = f.invoice_no
      AND u.stock_code = f.stock_code
      AND u.invoice_date = f.invoice_date
      AND u.quantity = f.quantity
      AND f.had_customer_id = TRUE
);

-- RESULT: 228,297 -- an exact match to unattributed_transactions' total
-- row count (confirmed at Query 96/97).

-- CONFIRMED FINDING: The bug is fully systematic, not partial. Every
-- single one of the 228,297 unattributed transactions is duplicated in
-- full_transactions -- none escaped it, and no unrelated rows were
-- caught by the EXISTS match either (228,297 affected exactly, not more,
-- not fewer). This confirms full_transactions' true, deduplicated
-- universe is simply clean_transactions itself (1,022,517 rows) --
-- unattributed_transactions contributes zero rows not already present in
-- clean_transactions, since it was built as a copy (Query 96), not a
-- split. See Query 151d for the corrected rebuild.