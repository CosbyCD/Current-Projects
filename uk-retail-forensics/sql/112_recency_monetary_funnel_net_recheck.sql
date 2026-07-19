-- Query 112_recency_monetary_funnel_net_recheck
-- WHAT: Rerun query 105's fixed 50-day bucket check (MAX and AVG monetary
--       per bucket), substituting monetary_net for monetary_gross, to
--       test whether the "lapsed whale" tail and the MAX-value spikes
--       seen in query 105 persist once cancelled orders are excluded
--       from the spend figure.
-- WHY: Query 111 found that customer 12346's £77,352.96 monetary_gross
--      outlier was almost entirely a bulk order placed and fully
--      cancelled 16 minutes later -- their real net spend is ~£169. This
--      calls into question whether the erratic MAX values and lapsed-
--      whale tail found in queries 105/106/109 reflect genuine high-value
--      dormant customers or are inflated by similarly cancelled bulk
--      orders. Per this project's gross-vs-net standing fork rule, both
--      versions are built and compared directly rather than assuming
--      gross and net tell the same story.

SELECT
    (recency_days / 50) * 50 AS recency_bucket_start,
    (recency_days / 50) * 50 + 49 AS recency_bucket_end,
    COUNT(*) AS customer_count,
    MAX(monetary_net) AS max_monetary_net,
    AVG(monetary_net) AS avg_monetary_net
FROM uk_retail.customer_behavior_fields
WHERE recency_days IS NOT NULL  -- excludes the 23 never-converted customers
GROUP BY (recency_days / 50)
ORDER BY recency_bucket_start;

-- RESULT (run July 18, 2026):
-- AVG monetary_net tracks AVG monetary_gross closely across all buckets --
-- same steady decay shape (5,404 -> 1,976 -> 1,851 -> ... -> 253). The
-- central-tendency funnel finding is unaffected by the gross/net switch.
-- MAX monetary_net dropped meaningfully in several buckets versus MAX
-- monetary_gross (query 105), most notably:
--   - 300-349 days: £77,352.96 -> £50,407.77 (-£26,945) -- customer
--     12346's cancelled bulk order (query 111) being excluded, as
--     predicted.
--   - 200-249 days: £44,534.30 -> £21,535.90 (-£22,998, -52%) -- a NEW,
--     previously unexamined drop, suggesting another customer with a
--     large cancelled order in this bucket. Not yet investigated.
--   - 350-399 days: £65,500.07 -> £54,692.82 (-£10,807) -- present but
--     smaller, not yet investigated.
--   - 600-649 days: £34,023.26 -> £30,375.26 (-£3,648) -- smaller still,
--     not yet investigated.
--
-- CONFIRMED FINDING: The revised funnel finding (average spend declines
-- steadily with recency; high-value outliers exist at every recency
-- level) survives the gross-to-net switch, but the SIZE of several
-- outliers shrinks once cancelled orders are excluded -- confirming that
-- monetary_gross meaningfully overstates the "lapsed whale" tail in
-- multiple buckets, not just customer 12346's. The 200-249 day bucket's
-- £23K drop flags a new, unexamined customer with a likely cancelled-
-- order pattern similar to 12346 -- see query 116.