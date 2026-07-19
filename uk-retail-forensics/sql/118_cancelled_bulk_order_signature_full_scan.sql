-- Query 118_cancelled_bulk_order_signature_full_scan
-- WHAT: Scan the full customer_behavior_fields table for every customer
--       whose monetary_gross substantially exceeds monetary_net (large
--       absolute AND large percentage gap) while frequency_completed is
--       low, matching the signature found independently in customer
--       12346 (query 111, 300-349 day bucket) and customer 15749 (query
--       116, 200-249 day bucket): very few total orders, with a large
--       cancellation inflating the gross figure far above real spend.
-- WHY: Two instances of the same signature were found by chasing
--      individual recency buckets one at a time (queries 111 and 116).
--      Per this project's standing rule, an ad hoc pattern found twice
--      should be tested systematically rather than continuing to search
--      bucket by bucket -- this replaces further one-off chasing with a
--      single full-dataset scan, and directly informs whether Chapter
--      Four's Tableau calculated fields should use monetary_gross or
--      monetary_net as the primary spend metric.

SELECT
    customer_id,
    recency_days,
    frequency_completed,
    cancellation_count,
    monetary_gross,
    monetary_net,
    (monetary_gross - monetary_net) AS gross_net_gap,
    ROUND(
        (monetary_gross - monetary_net) / NULLIF(monetary_gross, 0) * 100,
        1
    ) AS gap_pct_of_gross
FROM uk_retail.customer_behavior_fields
WHERE monetary_gross IS NOT NULL
  AND monetary_net IS NOT NULL
  AND frequency_completed <= 5
  AND (monetary_gross - monetary_net) > 1000
  AND (monetary_gross - monetary_net) / NULLIF(monetary_gross, 0) > 0.5
ORDER BY gross_net_gap DESC;

-- RESULT (run July 18, 2026):
-- 7 customers match the cancelled-bulk-order signature across the full
-- dataset:
--   12346: recency 325, freq 3, cancel 1, gross £77,352.96, net £169.36,
--          gap £77,183.60 (99.8% of gross)
--   15749: recency 234, freq 3, cancel 1, gross £44,534.30, net
--          £21,535.90, gap £22,998.40 (51.6% of gross)
--   12454: recency 52,  freq 4, cancel 3, gross £16,459.78, net
--          £4,098.96, gap £12,360.82 (75.1% of gross)
--   13091: recency 20,  freq 2, cancel 3, gross £1,108.80, net
--          -£1,343.24, gap £2,452.04 (221.1% of gross) -- NEGATIVE net,
--          cancellations exceed completed purchase value.
--   16077: recency 573, freq 1, cancel 1, gross £2,300.40, net £600.00,
--          gap £1,700.40 (73.9% of gross)
--   12607: recency 57,  freq 1, cancel 1, gross £1,579.51, net £0.00,
--          gap £1,579.51 (100.0% of gross)
--   14213: recency 371, freq 1, cancel 1, gross £1,192.20, net £0.00,
--          gap £1,192.20 (100.0% of gross)
-- Three customers (12607, 14213, and effectively 12346) show gross spend
-- that is entirely or almost entirely cancelled -- their real net
-- contribution is zero or near-zero despite substantial gross figures.
-- One customer (13091) shows negative net -- cancellations exceed
-- completed purchase value, a distinct anomaly from the others and
-- flagged for separate follow-up (see query 119).
--
-- CONFIRMED FINDING: Across the full 5,875-customer dataset,
-- monetary_gross materially overstates real customer value for at least
-- 7 identifiable customers, with effects ranging from moderate distortion
-- (51-75% gap) to complete inversion (100%+ gap, including one negative-
-- net case). This confirms the pattern first found individually in
-- queries 111 and 116 is systemic, not isolated. Despite this, the
-- aggregate/population-level funnel and quartile findings (queries 112,
-- 115) showed gross and net telling largely the same story in the
-- aggregate -- these 7 customers are individually significant but too
-- few to shift population-level quartile counts meaningfully.
-- RECOMMENDATION for Chapter Four: the primary dashboard spend metric
-- should default to monetary_net, since monetary_gross is demonstrably
-- unreliable as a proxy for real customer value at the individual-
-- customer level, even though it performs adequately in aggregate views.
-- Gross should remain available as a secondary/toggle metric, per this
-- project's standing both-forks rule, rather than being dropped.