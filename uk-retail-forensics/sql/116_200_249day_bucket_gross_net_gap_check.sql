-- Query 116_200_249day_bucket_gross_net_gap_check
-- WHAT: Pull every customer in the 200-249 day recency bucket, comparing
--       monetary_gross to monetary_net side by side, to identify which
--       customer(s) account for the £22,998 (-52%) drop in MAX monetary
--       value found when switching from gross (query 105) to net (query
--       112) in this bucket.
-- WHY: Query 112 found that MAX monetary_net in the 200-249 day bucket
--      dropped sharply versus MAX monetary_gross (query 105) -- a gap of
--      similar shape to customer 12346's cancelled-bulk-order pattern
--      (query 111), but in a different bucket and not yet attributed to
--      a specific customer. Per this project's standing rule, the gap
--      needs to be traced to its source before being written up.

SELECT
    customer_id,
    recency_days,
    monetary_gross,
    monetary_net,
    (monetary_gross - monetary_net) AS gross_net_gap,
    frequency_completed,
    cancellation_count
FROM uk_retail.customer_behavior_fields
WHERE recency_days BETWEEN 200 AND 249
ORDER BY gross_net_gap DESC;

-- RESULT (run July 18, 2026):
-- Customer 15749 accounts for nearly the entire £22,998.40 gap in this
-- bucket: recency 234 days, monetary_gross £44,534.30, monetary_net
-- £21,535.90, gap £22,998.40 -- only 3 completed orders, 1 cancellation.
-- Same signature as customer 12346 (query 111): very few total orders,
-- one cancelled, inflating gross spend by a large multiple of the
-- customer's real net spend.
-- The next-largest gap in this bucket is customer 12755 at £2,606.76 --
-- an order of magnitude smaller -- confirming this bucket's gross/net
-- distortion is a single-customer effect, not a systemic pattern across
-- many customers in this bucket.
-- Also noted in passing: customer 16446 (the 80,995-unit outlier from
-- Chapter Two's cleaning pass) appears here at £2.90 gross/net with zero
-- gap -- consistent with that outlier having been properly handled
-- already, not a new issue.
--
-- CONFIRMED FINDING: The 200-249 day bucket's gross/net gap is driven
-- almost entirely by customer 15749, who shows the same cancelled-bulk-
-- order signature as customer 12346 (query 111) -- very low frequency,
-- one large cancellation. This is now the second instance of this exact
-- pattern found via one-off bucket chasing. Rather than continuing to
-- chase remaining buckets individually, see query 118 for a general
-- pattern-detection query built to find all customers matching this
-- signature across the full dataset at once.