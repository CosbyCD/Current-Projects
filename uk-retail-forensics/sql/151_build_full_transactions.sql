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