-- ============================================================
-- QUERY 185 — Frequency Spike Tier — Customer-Level Export
--            (Top Decile vs. Below Top Decile)
-- ============================================================
-- WHAT: Pulls customer_id, recency_days, frequency_completed, and monetary_net
-- from uk_retail.customer_behavior_fields, tagging each customer into a
-- two-tier spike classification — 'Top Decile (Spike Zone)' vs.
-- 'Below Top Decile' — based on the £5,224.448 monetary_net threshold,
-- filtered to exclude any rows with null monetary_net, frequency_completed,
-- or recency_days.
--
-- WHY: The Chapter Three frequency-spike finding (top-decile concentration,
-- not top 15–20%) was originally confirmed at aggregate/SQL level, but
-- frequency_spike_tier_isolated_3d.html needed to be rebuilt as a proper 3D
-- exhibit — the prior version was a broken 2D-bar Python/Plotly export. A
-- native two-trace scatter3d exhibit (one trace per tier) requires
-- row-level, per-customer data so Plotly's built-in legend click/
-- double-click isolation works without custom HTML swatches, per the
-- project's locked exhibit standard.
--
-- RESULT: 5,875 rows returned (full customer_behavior_fields population,
-- no rows excluded by the null filters). Split: 586 Top Decile
-- (Spike Zone), 5,289 Below Top Decile.
--
-- CONFIRMED FINDING: The £5,224.448 threshold reproduces the same
-- top-decile boundary established in the earlier aggregate-level
-- frequency-spike finding (Query 128, confirmed against Tableau at 586),
-- now exported at customer grain. This is the data source behind the
-- rebuilt frequency_spike_tier_isolated_3d.html exhibit (two scatter3d
-- traces, shared cmin/cmax Viridis colorscale by log-scaled net spend).
-- ============================================================

SELECT
    customer_id,
    recency_days,
    frequency_completed,
    monetary_net,
    CASE WHEN monetary_net >= 5224.448
         THEN 'Top Decile (Spike Zone)'
         ELSE 'Below Top Decile'
    END AS spike_tier
FROM uk_retail.customer_behavior_fields
WHERE monetary_net IS NOT NULL AND frequency_completed IS NOT NULL AND recency_days IS NOT NULL;