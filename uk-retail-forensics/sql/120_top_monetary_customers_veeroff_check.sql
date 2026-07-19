-- Query 120_top_monetary_customers_veeroff_check
-- WHAT: Pull the top 20 customers by monetary_gross, alongside their
--       recency_days and frequency_completed, to identify which
--       customer(s) sit furthest from the main cluster on the recency or
--       frequency axis relative to their monetary rank -- the SQL
--       equivalent of the "veer-off" visually observed in the RFM cube's
--       high-monetary (yellow) region.
-- WHY: The veer-off observation (Chapter Three, log) was never assigned
--      specific axis values or a customer at the time it was seen --
--      several rounds of screenshot review this session narrowed it to
--      the RFM cube's high-monetary zone, but no query has yet pinned it
--      to an actual customer. Per this project's standing rule
--      (visualization suggests, SQL confirms), this replaces further
--      screenshot-based guessing with a direct data pull.

SELECT
    customer_id,
    recency_days,
    frequency_completed,
    monetary_gross,
    monetary_net
FROM uk_retail.customer_behavior_fields
WHERE monetary_gross IS NOT NULL
ORDER BY monetary_gross DESC
LIMIT 20;

-- RESULT (run July 18, 2026):
-- Top 20 customers by monetary_gross, with recency and frequency:
--   18102: recency 0,   freq 145, gross £580,987.04
--   14646: recency 1,   freq 146, gross £526,751.52
--   14156: recency 9,   freq 144, gross £303,069.88
--   14911: recency 0,   freq 373, gross £272,252.79
--   17450: recency 7,   freq 51,  gross £244,784.25
--   13694: recency 3,   freq 143, gross £195,640.69
--   17511: recency 2,   freq 60,  gross £172,132.87
--   16684: recency 3,   freq 55,  gross £147,142.77
--   12415: recency 23,  freq 24,  gross £144,033.37
--   15061: recency 3,   freq 127, gross £126,387.57
--   15311: recency 0,   freq 207, gross £114,671.42
--   13089: recency 2,   freq 203, gross £113,416.91
--   16029: recency 38,  freq 106, gross £109,620.87
--   17949: recency 0,   freq 116, gross £107,833.48
--   12931: recency 21,  freq 57,  gross £92,347.34
--   14298: recency 2,   freq 82,  gross £91,194.49
--   15769: recency 6,   freq 46,  gross £88,612.52
--   12346: recency 325, freq 3,   gross £77,352.96   <-- OUTLIER
--   13798: recency 0,   freq 110, gross £75,428.87
--   15838: recency 10,  freq 34,  gross £73,205.50
-- Every customer in this top-20 list sits at recency 0-38 days EXCEPT
-- customer 12346, at recency 325 days -- an order of magnitude further
-- out than any other high-monetary customer, while still ranking in the
-- same monetary tier. This is the exact pattern described in the
-- Chapter Three veer-off observation: a point breaking away from the
-- main high-monetary cluster along the recency axis.
--
-- CONFIRMED FINDING: The Chapter Three veer-off observation and customer
-- 12346 (already investigated in Query 111_customer_12346_order_history_
-- check) are the SAME finding, arrived at by two different paths -- chart
-- rotation first in Chapter Three, SQL ranking first here. No new
-- investigation is required: Query 111 already established that 12346's
-- £77,352.96 monetary_gross is almost entirely a single 74,215-unit bulk
-- order cancelled 16 minutes after being placed, with real net spend of
-- ~£169.36. The veer-off observation is CLOSED as of this query -- see
-- the investigation log for the formal revision notation on the original
-- Chapter Three entry.