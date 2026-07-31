-- Query 151b_full_transactions_duplicate_check

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

-- CONFIRMED FINDING: The TRUE/FALSE pairing on matching rows directly
-- confirms the double-counting bug hypothesized in Query 151's revision
-- note -- the same physical transaction line is present once via
-- clean_transactions (mislabeled had_customer_id = TRUE) and once via
-- unattributed_transactions (correctly FALSE). This is row-level proof,
-- not inference from a total. Scope not yet known from this sample alone
-- -- see Query 151c for the full count.