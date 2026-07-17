-- ============================================================
-- EXPLORATION: Full field export for correlation heatmap and
--              interval/diversity/return-rate cube exploration
-- WHAT: Exports all derived fields from customer_behavior_fields,
--       including both versions of interval, diversity, and
--       return rate, for an informal "for giggles" first look
--       at the untouched field territory — not a hypothesis-
--       driven query.
-- WHY: Sprint 6's open item 4 (remaining field-trio
--      explorations) has not been started. This is the data
--      pull needed for a correlation heatmap (fast orientation)
--      and a baseline 3D cube using interval/diversity/return
--      rate. WHERE clause matches the same 5,852-customer
--      population used throughout Chapter Three — no mid-
--      stream dataset changes.
-- ============================================================
SELECT
    customer_id,
    recency_days,
    frequency_completed,
    cancellation_count,
    monetary_gross,
    monetary_net,
    avg_interval_whole_day,
    avg_interval_fractional_day,
    distinct_variants_purchased,
    distinct_families_purchased,
    order_return_rate_pct,
    line_item_return_rate_pct
FROM uk_retail.customer_behavior_fields
WHERE frequency_completed IS NOT NULL
ORDER BY customer_id;