-- ============================================================
-- VERIFICATION: Recency gap check — 25-day bins
-- WHAT: Bins all customers by recency_days into 25-day buckets
--       and counts customers per bucket, to check whether the
--       apparent gap in the 100-250 day range (observed while
--       rotating the 3D chart) is a real drop in customer
--       density or a rendering/overplotting artifact.
-- WHY: Sprint 6 flagged a possible two-cluster split around
--      100-250 days as a candidate finding, explicitly not
--      confirmed. Per the project's verification workflow,
--      anything seen only in a chart rotation needs a SQL/stats
--      check before it becomes a documented finding.
-- ============================================================
SELECT
    (recency_days / 25) * 25 AS recency_bucket_start,
    (recency_days / 25) * 25 + 24 AS recency_bucket_end,
    COUNT(*) AS customer_count
FROM uk_retail.customer_behavior_fields
WHERE recency_days IS NOT NULL  -- excludes the 23 never-converted customers
GROUP BY (recency_days / 25)
ORDER BY recency_bucket_start;