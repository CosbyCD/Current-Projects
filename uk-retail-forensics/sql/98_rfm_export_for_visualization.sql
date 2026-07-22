-- Query 98_rfm_export_for_visualization

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

-- RESULT: 5,875 rows exported (matching customer_behavior_fields'
-- full row count from Query 94), ordered by customer_id. Of these,
-- 23 rows carry NULL in both frequency_completed and monetary_gross
-- (customer_ids: 12896, 13342, 13353, 13749, 14120, 14337, 14763,
-- 14864, 14914, 14925, 15767, 15997, 16220, 16512, 16580, 16853,
-- 16995, 17485, 17632, 17641, 17645, 17661, 17755) — all with high
-- recency_days values (371-738 days), consistent with never having
-- a completed order. recency_days is populated for every row with
-- no NULLs, since it's built from an unconditional customer_id scan
-- with no invoice-type filter.

-- CONFIRMED FINDING: This export directly verifies the structural
-- NULL behavior anticipated at Query 94 — customers whose only
-- activity is cancelled invoices produce NULL (not zero) values in
-- frequency_completed and monetary_gross, because both are built
-- from CTEs filtered to invoice_no NOT LIKE 'C%'. This also
-- independently confirms the investigation_log's forward reference
-- (Chapter Three intro) to a "5,852-customer dataset, 23
-- never-converted cancellation-only customers held out" — 5,875
-- total minus these 23 NULL rows equals exactly 5,852. Since these
-- 23 customers cannot be positioned in 3D RFM space without a
-- frequency or monetary coordinate, they must be excluded (not
-- zero-filled, which would misrepresent them as low-engagement
-- rather than never-converted) before the visualization is built.