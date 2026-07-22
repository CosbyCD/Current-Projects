-- Query 99_recency_gap_histogram_check

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

-- RESULT: 30 buckets (0-24 through 725-749), summing to 5,875
-- customers — NOT 5,852. The WHERE recency_days IS NOT NULL clause
-- does not exclude the 23 never-converted customers as the comment
-- claims; those customers have valid recency_days values (only
-- frequency_completed and monetary_gross are NULL for them, per
-- Query 94/98). The clause is a no-op on this table. Counts in the
-- hypothesized 100-249 gap range are 167, 143, 159, 145, 123, 123 —
-- a smooth continuation of the decline already underway from the
-- 75-99 bucket (267), not a distinct valley. The most pronounced
-- irregularity in the full distribution is later: a low of 41 at
-- 325-349, followed by a rebound to 152, 258, 208 across 350-424.

-- CONFIRMED FINDING: The Sprint 6 hypothesis of a two-cluster split
-- at 100-250 days is NOT confirmed by this histogram — counts in
-- that range follow the same gradual decline as the surrounding
-- buckets rather than showing a sudden drop, so what was seen while
-- rotating the 3D chart does not hold up as a real density gap.
-- Separately, this comment block's own claim about excluding the
-- 23 never-converted customers is incorrect (WHERE recency_days IS
-- NOT NULL excludes nothing on this table, since recency_days has
-- no NULLs) — flagged here rather than silently corrected, per the
-- preserve-the-original-record rule. A new, unhypothesized pattern
-- surfaced instead: a genuine dip-then-rebound around 325-424 days,
-- which is a stronger candidate for a real secondary cluster and
-- warrants its own follow-up query before being treated as a
-- finding.