-- Query 69_monetary_net_rebuild

-- ============================================================
-- CHAPTER TWO, FIELD 3 REBUILD: Monetary Value — net
-- WHAT: Re-runs monetary_net (originally query 55) against the
--       amended clean_transactions.
-- WHY: Query 57 traced the exact-doubling anomaly (customers
--       16446, 12918, 14802, 15802, 13290) to administrative
--       "Manual" and similar entries. This rebuild should
--       resolve the anomaly for all five customers, not just
--       12918, since the underlying rows are now excluded at
--       the source across the board.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_net
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY monetary_net DESC;

-- RESULT: Top customer 18102 confirmed unchanged at $578,408.64,
-- matching the log exactly. 5,875 rows -- the full current customer
-- population, matching Query 65's all-orders population (no
-- cancellation filter). Confirmed: 12918, 14802, 15802, and 13290 are
-- all absent, consistent with their complete removal in Query 63/67/
-- 68. Customer 16446, still present, shows monetary_net = $2.90 --
-- up from -$6.10 pre-amendment, a shift of exactly $9.00, small and
-- consistent with removing a minor sliver of administrative
-- contamination rather than resolving a major anomaly.

-- CONFIRMED FINDING: This query's own WHY block, carried over from
-- when it was originally written, still frames the anomaly as
-- affecting "all five customers" (16446, 12918, 14802, 15802, 13290)
-- -- but per the correction already established at Query 56, 16446
-- was never a true exact-mirror case, and this result confirms that
-- distinction plays out exactly as expected: the four genuine
-- administrative-contamination customers (12918, 14802, 15802, 13290)
-- are fully resolved by disappearing from the table entirely, while
-- 16446 remains present with only a small $9.00 shift -- their
-- near-total-cancellation pattern (large gross, near-zero net) is
-- essentially unchanged and confirmed as genuine customer cancellation
-- behavior, not administrative noise. This is the clearest direct
-- confirmation yet that 16446 and the other four belong in separate
-- categories, exactly as Query 56's correction stated.