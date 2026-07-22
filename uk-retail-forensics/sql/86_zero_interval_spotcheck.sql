-- Query 86_zero_interval_spotcheck

-- ============================================================
-- VERIFICATION: Zero-day interval cluster — spot-check
-- WHAT: Pulls the actual invoice numbers and timestamps for one
--       customer showing orders_used_in_calc > 1 with
--       avg_days_between_orders = 0.0, to confirm this reflects
--       genuine same-day repeat orders rather than a data or
--       query artifact.
-- WHY: Query 85 showed a large cluster of customers with a
--      0.0-day average interval. Worth confirming directly
--      before accepting the field as final, consistent with
--      this project's standard practice.
-- ============================================================
SELECT invoice_no, MIN(invoice_date) AS order_time
FROM uk_retail.clean_transactions
WHERE customer_id = '18139'
AND invoice_no NOT LIKE 'C%'
GROUP BY invoice_no
ORDER BY order_time;

-- RESULT: 6 completed orders for customer 18139, spanning 2011-11-21
-- 14:06 through 2011-11-22 10:44 -- four orders clustered within
-- roughly 2.25 hours on the same calendar day (14:06, 14:47, 15:53,
-- 16:20), then two more the following morning (09:17, 10:44), about
-- 17 hours after the last same-day order. This confirms the 0.0-day
-- average is not a data or query artifact -- these are genuine,
-- closely-spaced repeat orders that a whole-day EXTRACT(DAY FROM ...)
-- measurement rounds down to zero, even though real elapsed time
-- (hours, not zero) separates every one of them.

-- CONFIRMED FINDING: The zero-day interval cluster is confirmed
-- genuine, not an error -- but it exposes a real measurement-precision
-- limitation in the whole-day interval logic. This directly motivates
-- building a fractional-day version alongside it, consistent with
-- this project's standing practice of building both sides of a
-- genuine measurement fork rather than settling on one definition in
-- advance. See the next queries for the whole-day/fractional-day
-- comparison this spot-check prompted.