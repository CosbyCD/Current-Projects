-- Query 40_nearby_customer_ids_expanded_check

-- ============================================================
-- FOLLOW-UP: Nearby customer_id check — expanded range
-- WHAT: Re-runs the query 30 neighbor comparison with a much
--       wider numeric range around 13256 (13226–13866) instead
--       of the original narrow window (13246–13266).
-- WHY: Query 30 only checked a tight sequential neighborhood,
--      which would catch a simple left/right digit slip but
--      would miss other realistic data-entry errors — a
--      mistyped digit doesn't have to land immediately adjacent
--      in numeric sequence; it can be off by a wider margin
--      depending on how the error actually happened (a keypad
--      slip, a fingernail catching an adjacent key vertically
--      as well as horizontally). Widening the range gives a
--      fuller picture of whether 13256's single-order anomaly
--      is unique in a broader neighborhood, not just its
--      immediate numeric neighbors.
-- ============================================================
SELECT customer_id, COUNT(*) AS order_count
FROM uk_retail.raw_transactions
WHERE TRIM(customer_id) != ''
AND customer_id::NUMERIC BETWEEN 13226 AND 13866
GROUP BY customer_id
ORDER BY customer_id;

-- RESULT: A much larger set of customer_ids returned across the
-- expanded range, with order counts spanning from 1 up to 1,920 (customer
-- 13263). At least fifteen other customer_ids in this wider window also
-- show exactly 1 order, alongside 13256 -- meaning the original
-- Query 30 conclusion does not hold up under a wider test. "Exactly 1
-- order" is common across this broader neighborhood; it only appeared
-- unique to 13256 because Query 30's narrow 21-ID window happened not
-- to include any of the other single-order customers sitting slightly
-- further out.

-- CONFIRMED FINDING: The earlier finding from Query 30 -- that 13256's
-- single order made it stand out from its neighbors -- did not survive
-- this wider test and needed to be revised rather than defended.
-- Single-order customers are a normal, recurring pattern across this
-- broader customer_id neighborhood, not a rarity specific to 13256.
-- This reframes, but does not overturn, the underlying outlier finding
-- from Query 29 -- the actual anomaly remains specific to that one
-- order's content (a 12,540-unit, zero-price line item), not to
-- 13256 having a low order count in general. The wider pull did surface
-- a real, more specific lead worth pursuing directly: this broader
-- window contains established, active customer_ids that sit exactly
-- one digit-transposition away from 13256 -- far more plausible
-- candidates for "the row's true intended customer" than order-count
-- comparison alone could show. See Query 41 for the direct test of
-- those specific candidates.