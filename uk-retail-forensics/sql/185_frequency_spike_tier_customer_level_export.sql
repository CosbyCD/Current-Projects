-- Query 185_frequency_spike_tier_customer_level_export

-- WHAT: Pulls customer_id, recency_days, frequency_completed, and monetary_net
-- from uk_retail.customer_behavior_fields, tagging each customer into a
-- two-tier spike classification -- 'Top Decile (Spike Zone)' vs.
-- 'Below Top Decile' -- based on the £5,224.448 monetary_net threshold,
-- filtered to exclude any rows with null monetary_net, frequency_completed,
-- or recency_days.

-- WHY: The Chapter Three frequency-spike finding (top-decile concentration,
-- not top 15-20%) was originally confirmed at aggregate/SQL level, but
-- frequency_spike_tier_isolated_3d.html needed to be rebuilt as a proper 3D
-- exhibit -- the prior version was a broken 2D-bar Python/Plotly export. A
-- native two-trace scatter3d exhibit (one trace per tier) requires
-- row-level, per-customer data so Plotly's built-in legend click/
-- double-click isolation works without custom HTML swatches, per the
-- project's locked exhibit standard.

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

-- RESULT: 5,852 rows returned, not the 5,875 originally stated in an
-- earlier draft of this comment block. The gap is fully explained:
-- customer_behavior_fields has 5,875 total rows, but the WHERE clause's
-- NOT NULL filters exclude the 23 never-converted (cancellation-only)
-- customers first confirmed at Query 98/99 -- these carry NULL in
-- frequency_completed and monetary_net structurally, not by data error,
-- since both fields are built from CTEs filtered to invoice_no NOT LIKE
-- 'C%'. 5,875 - 23 = 5,852, exact match. Split: 586 Top Decile (Spike
-- Zone), 5,266 Below Top Decile -- the originally stated 5,289 Below Top
-- Decile was written as if the WHERE clause excluded nothing; correcting
-- it by the same 23 confirms the figure. 586 was never affected, since
-- none of the 23 excluded customers carry a monetary_net value to
-- threshold against.

-- CONFIRMED FINDING: The £5,224.448 threshold reproduces the same
-- top-decile boundary established in the earlier aggregate-level
-- frequency-spike finding (Query 128, confirmed against Tableau at 586),
-- now exported at customer grain -- the 586 figure is independently
-- confirmed twice (Query 128, this CSV). This is the data source behind
-- the rebuilt frequency_spike_tier_isolated_3d.html exhibit (two
-- scatter3d traces, shared cmin/cmax Viridis colorscale by log-scaled
-- net spend).