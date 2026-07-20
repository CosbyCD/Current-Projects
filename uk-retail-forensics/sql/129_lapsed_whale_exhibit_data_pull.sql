-- Query 129_lapsed_whale_exhibit_data_pull
-- WHAT: Pull recency_days, frequency_completed, monetary_net, and a
--       lapsed_whale flag (per the confirmed fixed dual-threshold
--       definition: recency_days >= 377 AND monetary_net >= 2180.28)
--       for the full customer population, to build a dedicated 3D
--       exhibit that visually isolates the 58 confirmed lapsed whales
--       against the rest of the customer base.
-- WHY: The Chapter Four Tableau drill-down for "Lapsed Whale" needs its
--      own purpose-built 3D exhibit, not a reused general-population
--      chart or the 2D gut-check summary (which was mistakenly used as
--      a placeholder and confirmed not to be the right fit). This pulls
--      the data needed to build that exhibit, using the same fixed
--      dual-threshold definition finalized in queries 122/126/127.

SELECT
    customer_id,
    recency_days,
    frequency_completed,
    monetary_net,
    CASE
        WHEN recency_days >= 377 AND monetary_net >= 2180.28
        THEN 'Lapsed Whale'
        ELSE 'Other'
    END AS whale_flag
FROM uk_retail.customer_behavior_fields
WHERE recency_days IS NOT NULL AND monetary_net IS NOT NULL
ORDER BY whale_flag DESC, monetary_net DESC;

-- RESULT (run July 19, 2026):
-- Full population pulled: 5,852 customers total, split as 58 Lapsed
-- Whale / 5,794 Other -- matching the confirmed fixed dual-threshold
-- count from queries 126/127 exactly.
-- Data used to build a dedicated 3D Plotly exhibit
-- (lapsed_whale_isolated_3d.html) isolating the 58 confirmed lapsed
-- whales in gold against the full population in gray, replacing an
-- earlier mistaken placeholder mapping that pointed the Chapter Four
-- "Lapsed Whale" drill-down at the 2D gut-check summary instead of a
-- true 3D deep-dive.
--
-- CONFIRMED FINDING: The 58-customer lapsed-whale definition is
-- reproducible and consistent when pulled fresh for exhibit-building
-- purposes, matching queries 126/127 exactly. The resulting exhibit
-- fulfills the original Chapter Four design intent (purpose-built 3D
-- deep-dives, not reused general charts) for the funnel's headline
-- finding. Wired into the "Exhibit URL (Funnel Tier)" calculated field
-- as the "Lapsed Whale" drill-down target.