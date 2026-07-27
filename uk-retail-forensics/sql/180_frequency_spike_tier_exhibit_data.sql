-- Query 180_frequency_spike_tier_exhibit_data

-- WHAT: Pulls the 586-customer Top Decile / Frequency Spike population
--       (Query 128's threshold: monetary_net >= £5,224.45) with
--       recency_days, frequency_completed, and monetary_net -- the same
--       three axes as the existing RFM cubes (uk_retail_rfm_3d_log.html,
--       lapsed_whale_isolated_3d.html, etc.), so this new exhibit
--       matches the established visual language of the rest of the
--       gallery before any customization is considered.
-- WHY: No dedicated exhibit currently exists for the Frequency Spike
--      Tier field -- it has no drill-down target. Building at the
--      natural default (same axes, same style as every other
--      customer-side cube) first, per instruction, before evaluating
--      whether something more targeted is worth building instead.

SELECT
    customer_id,
    recency_days,
    frequency_completed,
    monetary_net
FROM uk_retail.customer_behavior_fields
WHERE monetary_net IS NOT NULL
  AND ROUND(monetary_net, 2) >= 5224.45
ORDER BY monetary_net DESC;

-- RESULT: 586 rows returned, matching Query 128's confirmed 90th-percentile
-- population exactly (10.0% of the ~5,852-customer converted population).
-- Zero NULLs across all three pulled fields (recency_days, frequency_completed,
-- monetary_net) -- expected, since the WHERE clause already excludes
-- monetary_net IS NULL, and a customer with NULL monetary_net could never
-- satisfy the >= 5224.45 threshold regardless. Range summary from the
-- exported CSV (180_frequency_spike_tier_exhibit_data.csv):
--   - monetary_net: £5,224.85 (min) to £578,408.64 (max, customer 18102)
--   - recency_days: 0 (min) to 691 (max)
--   - frequency_completed: 1 (min) to 373 (max)
-- The observed minimum monetary_net (£5,224.85) is slightly above the
-- £5,224.45 threshold itself -- expected, not a discrepancy: no customer's
-- actual value happened to fall in the narrow [5224.45, 5224.85) gap, which
-- is unremarkable given the population is discrete individual customer totals,
-- not a continuous distribution guaranteed to hit the exact boundary.

-- CONFIRMED FINDING: The Frequency Spike Tier population (586 customers,
-- 90th-percentile-plus by net spend) spans an extremely wide range on every
-- axis -- recency from same-day (0) to nearly two years lapsed (691 days),
-- and frequency from a single completed order to 373. This confirms the tier
-- is not a narrow, homogeneous "big spender" segment: it includes very-recent
-- high-single-order customers alongside long-lapsed high-frequency customers,
-- which is exactly the kind of internal variation a rotatable 3D exhibit is
-- suited to surface that a single summary statistic would obscure. This data
-- pull is the direct input for frequency_spike_tier_isolated_3d.html.