-- ============================================================
-- EXPLORATION: High return rate / low frequency cluster
-- WHAT: Pulls full customer_behavior_fields detail for customers
--       with order_return_rate_pct > 30 AND frequency_completed
--       < 10, the cluster visually isolated while rotating the
--       cancellation/return-rate/frequency cube.
-- WHY: 3D rotation showed this group sitting distinctly apart
--      from the main population rather than as its sparse tail
--      -- low frequency, wide range of return rate (20-60%),
--      not tracking with cancellation count the way the
--      correlation matrix's moderate 0.41 value might suggest.
--      Confirming who these customers actually are before
--      writing this up as a finding.
-- ============================================================
SELECT
    customer_id,
    recency_days,
    frequency_completed,
    cancellation_count,
    monetary_gross,
    monetary_net,
    order_return_rate_pct,
    line_item_return_rate_pct,
    distinct_variants_purchased,
    distinct_families_purchased
FROM uk_retail.customer_behavior_fields
WHERE order_return_rate_pct > 30
  AND frequency_completed < 10
ORDER BY order_return_rate_pct DESC;