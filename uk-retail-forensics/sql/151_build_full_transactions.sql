-- Query 151_build_full_transactions

-- WHAT: Builds uk_retail.full_transactions as the union of
--       clean_transactions (customer-attributed, 1,028,437 rows) and
--       unattributed_transactions (no customer_id, 228,297 rows,
--       confirmed clean at Query 96/97), with the customer_id column
--       dropped and a provenance flag added to track which source
--       pool each row came from.
-- WHY: Chapter Five (MRP/inventory sprint) needs the full universe of
--      real transaction activity, not just the customer-attributed
--      subset -- inventory movement doesn't care who bought it. Per
--      this project's segregate-don't-delete standard, dropping
--      customer_id doesn't mean losing traceability: the
--      had_customer_id flag preserves which source pool every row
--      came from, so this table can always be decomposed back to its
--      two origins if needed.

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

-- RESULT: 1,250,814 rows returned, not the 1,256,734 that a naive read of
-- this query's WHAT block (1,028,437 + 228,297) would suggest. Traced and
-- fully resolved: unattributed_transactions checks out exactly at 228,297
-- via direct COUNT(*), and clean_transactions independently counts at
-- 1,022,517, not 1,028,437. This is NOT an unexplained drift -- it's
-- already documented elsewhere in this log. clean_transactions was
-- amended twice after Chapter One's formal close: Query 59 (administrative
-- stock-code exclusion) brought it from 1,028,437 to 1,022,519 (-5,918
-- rows), and Query 74 (stock_code 23843 outlier exclusion) brought it to
-- 1,022,517 (-2 rows). 1,028,437 - 5,918 - 2 = 1,022,517, exact match.
-- This query's WHAT block simply cited the pre-amendment Chapter One
-- figure rather than the amended one; the table itself has been correct
-- throughout. 1,022,517 + 228,297 = 1,250,814, confirming full_transactions
-- is built correctly against current table state.

-- CONFIRMED FINDING: full_transactions is built correctly at 1,250,814
-- rows, fully reconciled against both source tables as they actually
-- stand today. The apparent discrepancy was a stale row-count reference
-- in this query's own WHAT block, not a data integrity issue -- resolved
-- by cross-referencing queries 59 and 74, both already on record. This
-- query's WHAT block should be corrected to state 1,022,517 (not
-- 1,028,437) for clean_transactions going forward.

-- [REVISION, confirmed via direct query] The 1,250,814 figure and the
-- CONFIRMED FINDING above are superseded. This query has a real bug, not
-- a documentation gap: clean_transactions still contains the 228,297
-- unattributed (NULL customer_id) rows, per Query 96's own note that
-- "clean_transactions itself is left completely unchanged" when
-- unattributed_transactions was split out as a copy, not a removal. This
-- query selects the FULL clean_transactions table with no
-- customer_id IS NOT NULL filter, hardcoding TRUE AS had_customer_id on
-- every row -- including the embedded unattributed ones -- then unions
-- that against unattributed_transactions, which is a copy of those exact
-- same rows. Verified directly: a duplicate-check query found matching
-- invoice_no/stock_code/invoice_date/quantity rows present as both
-- had_customer_id = TRUE and FALSE; a full count of affected rows
-- returned exactly 228,297 -- an exact match to unattributed_transactions'
-- total row count, confirming every single unattributed row is
-- double-counted, not a coincidental subset. Since unattributed_transactions
-- contributes zero rows not already present in clean_transactions,
-- full_transactions' correct universe is simply clean_transactions itself:
-- 1,022,517 rows, not 1,250,814. The query needs a
-- "WHERE customer_id IS NOT NULL" filter added to its clean_transactions
-- branch before the UNION ALL, or equivalently, could be rebuilt as a
-- single SELECT against clean_transactions with had_customer_id derived
-- as CASE WHEN customer_id IS NULL THEN FALSE ELSE TRUE END, since
-- unattributed_transactions adds no new information to this table.
--
-- DOWNSTREAM IMPACT, NOT YET ASSESSED: stock_behavior_fields (Query 159,
-- 4,734 SKUs) is built from this table, and Chapter Five's headline
-- findings (572 Overdue Restock / 93 Seasonal Dormant / 108 Dead Stock)
-- are built from stock_behavior_fields. Any SKU appearing in an
-- unattributed transaction had its frequency/quantity aggregates
-- inflated by this bug. full_transactions and stock_behavior_fields both
-- need to be rebuilt from the corrected query, and the 572/93/108 figures
-- re-verified against the corrected numbers before being treated as
-- final. Flagged, not yet corrected -- this revision documents the bug,
-- it does not yet fix the downstream tables.

-- ============================================================
-- Query 151b_full_transactions_duplicate_check
-- ============================================================
-- WHAT: Groups full_transactions by invoice_no, stock_code, invoice_date,
-- quantity, and had_customer_id, returning any group with more than one
-- row -- surfacing exact duplicate line items rather than assuming the
-- table is clean because its total row count reconciles.
-- WHY: Query 151's own RESULT check couldn't distinguish a correct union
-- from a systematically duplicated one -- both produce the same total row
-- count if clean_transactions still contains the rows unattributed_
-- transactions was copied from (confirmed at Query 96). This query tests
-- that directly, at the row level, instead of trusting the total.

SELECT invoice_no, stock_code, invoice_date, quantity, had_customer_id, COUNT(*)
FROM uk_retail.full_transactions
GROUP BY invoice_no, stock_code, invoice_date, quantity, had_customer_id
HAVING COUNT(*) > 1
LIMIT 20;

-- RESULT: 20 rows returned (LIMIT reached). The large majority show the
-- same invoice_no/stock_code/invoice_date/quantity combination appearing
-- twice under had_customer_id = TRUE and twice under FALSE -- e.g.
-- invoice 489856, stock_code 22111, qty 5: 2 rows TRUE, 2 rows FALSE.
-- Two rows (invoice 492079, stock_code 85042; invoice 492760, stock_code
-- 21143) show TRUE, count=2 with no FALSE counterpart -- a separate,
-- unrelated pre-existing duplicate pair inside clean_transactions itself,
-- not part of the unattributed double-count pattern.
--
-- CONFIRMED FINDING: The TRUE/FALSE pairing on matching rows directly
-- confirms the double-counting bug hypothesized in Query 151's revision
-- note -- the same physical transaction line is present once via
-- clean_transactions (mislabeled had_customer_id = TRUE) and once via
-- unattributed_transactions (correctly FALSE). This is row-level proof,
-- not inference from a total. Scope not yet known from this sample alone
-- -- see Query 151c for the full count.
-- ============================================================

-- ============================================================
-- Query 151c_full_transactions_duplicate_count
-- ============================================================
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
--
-- CONFIRMED FINDING: The bug is fully systematic, not partial. Every
-- single one of the 228,297 unattributed transactions is duplicated in
-- full_transactions -- none escaped it, and no unrelated rows were
-- caught by the EXISTS match either (228,297 affected exactly, not more,
-- not fewer). This confirms full_transactions' true, deduplicated
-- universe is simply clean_transactions itself (1,022,517 rows) --
-- unattributed_transactions contributes zero rows not already present in
-- clean_transactions, since it was built as a copy (Query 96), not a
-- split. See Query 151d for the corrected rebuild.
-- ============================================================

-- ============================================================
-- Query 151d_build_full_transactions_corrected
-- ============================================================
-- WHAT: Rebuilds full_transactions correctly, fixing the double-counting
-- bug confirmed above. Adds customer_id IS NOT NULL to the
-- clean_transactions branch so it no longer re-includes the 228,297
-- unattributed rows that unattributed_transactions already supplies.
-- WHY: See the [REVISION] block above -- the original Query 151 counted
-- every unattributed transaction twice, inflating full_transactions by
-- exactly 228,297 rows.

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