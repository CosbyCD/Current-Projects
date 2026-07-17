-- ============================================================
-- 3D VISUALIZATION, ITERATION 1 (RFM, Option 1 method): Data export
-- WHAT: Exports customer_id, recency_days, frequency_completed,
--       and monetary_gross from customer_behavior_fields — the
--       three classic RFM fields — for use as X/Y/Z coordinates
--       in the first 3D scatter visualization.
-- WHY: First iteration of the eventual 3D nodal visualization,
--      built the standard way (Option 1): one customer = one
--      point in space, positioned simultaneously by all three
--      RFM values. Gross monetary value and completed-only
--      frequency chosen consistent with standard RFM convention
--      and this project's established methodology (completed
--      orders reflect genuine engagement, not cancelled activity).
-- ============================================================
SELECT customer_id, recency_days, frequency_completed, monetary_gross
FROM uk_retail.customer_behavior_fields
ORDER BY customer_id;