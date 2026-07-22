-- Query 81_monetary_gross_rebuild_v3

-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD (v3): Monetary Value — gross
-- WHAT: Re-runs monetary_gross against clean_transactions after
--       the third amendment (query 74), which excluded the
--       80,995-unit stock_code 23843 outlier.
-- WHY: Customer 16446's monetary_gross was almost entirely
--      driven by the now-excluded 80,995-unit transaction
--      ($168,469.60 of their $168,472.50 total). This rebuild
--      should show their gross value drop to just the two
--      small legitimate items from invoice 553573 (roughly
--      $2.90 combined).
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY monetary_gross DESC;

-- RESULT: Top customer 18102 unchanged at $580,987.04, confirming the
-- third amendment doesn't touch their transaction history. 5,852 rows,
-- matching the prior rebuild's completed-only population exactly.
-- Customer 16446 confirmed at exactly $2.90 -- precisely the sum of
-- the two legitimate items already confirmed at the row level in
-- Query 71 ($1.65 scrubbing brush + $1.25 pastry brush), with the
-- $168,469.60 erroneous transaction now fully excluded.

-- CONFIRMED FINDING: PASSED. Customer 16446's monetary_gross dropped
-- from $168,472.50 to $2.90 -- a change of exactly $168,469.60,
-- matching the excluded transaction's value to the cent. This is the
-- direct field-level confirmation of what Query 71 established at the
-- row level: the customer's entire apparent purchase history was one
-- erroneous transaction sitting on top of two ordinary small
-- purchases, and removing the error reveals the genuine, modest
-- customer underneath. See Query 82 for the individual spot-check
-- confirming this directly, and Query 83 for the matching net rebuild.