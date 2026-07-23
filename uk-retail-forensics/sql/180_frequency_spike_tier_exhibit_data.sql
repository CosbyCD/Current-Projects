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