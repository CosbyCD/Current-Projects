-- Query 151d_build_full_transactions_corrected

-- WHAT: Rebuilds full_transactions correctly, fixing the double-counting
-- bug confirmed at Queries 151b and 151c. Adds customer_id IS NOT NULL
-- to the clean_transactions branch so it no longer re-includes the
-- 228,297 unattributed rows that unattributed_transactions already
-- supplies.
-- WHY: The original Query 151 counted every unattributed transaction
-- twice, inflating full_transactions by exactly 228,297 rows -- see
-- Query 151's own revision note and Queries 151b/151c for the full
-- diagnostic trail.

DROP TABLE IF EXISTS uk_retail.full_transactions;

CREATE TABLE uk_retail.full_transactions AS
SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    country,
    TRUE AS had_customer_id
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL

UNION ALL

SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    country,
    FALSE AS had_customer_id
FROM uk_retail.unattributed_transactions;

-- RESULT: 1,022,517 rows returned -- an exact match to clean_transactions'
-- own row count, confirmed via independent COUNT(*) earlier in this
-- investigation thread. Confirms the fix worked precisely as predicted:
-- with the customer_id IS NOT NULL filter applied, unattributed_
-- transactions contributes zero net-new rows (every one of its 228,297
-- rows was already present in clean_transactions), so full_transactions'
-- correct universe is simply clean_transactions itself.

-- CONFIRMED FINDING: full_transactions is now correctly built at
-- 1,022,517 rows, resolving the double-counting bug confirmed at Queries
-- 151b and 151c. This table should be treated as the authoritative
-- version going forward, superseding the original Query 151 build.
-- Anything built on top of the buggy version -- stock_behavior_fields
-- (Query 159, 4,734 SKUs) and Chapter Five's three headline findings
-- (572 Overdue Restock / 93 Seasonal Dormant / 108 Dead Stock) -- was
-- built on an inflated transaction universe and needs to be rebuilt and
-- re-verified against this corrected table before those figures can be
-- trusted as final. Not yet done; next step in this investigation thread.