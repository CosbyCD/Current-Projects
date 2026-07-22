-- Query 103_full_field_export_for_exploration

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

-- RESULT: 5,852 rows exported, correctly excluding all 23
-- never-converted customers identified at Query 98 (none of the 23
-- customer_ids appear in this export) — confirming, unlike Query
-- 99's WHERE recency_days IS NOT NULL clause, that this WHERE
-- clause does what it claims, since frequency_completed genuinely
-- carries NULL only for those 23 customers. 1,619 rows still
-- contain a NULL in at least one other field (most likely
-- avg_interval_whole_day/avg_interval_fractional_day for
-- single-completed-order customers, where the LAG-based gap
-- calculation has nothing to compare against — not yet verified
-- directly). This export also resolves the open item flagged at
-- Query 102: customer 17961's actual frequency_completed = 100,
-- recency_days = 20, cancellation_count = 2 — all matching the
-- direct order-history pull exactly. The WHAT block's "~120
-- completed orders" figure at Query 102 was simply incorrect.

-- CONFIRMED FINDING: The full-field export is verified correct at
-- 5,852 rows for the Chapter Three population, with the NULL
-- exclusion working as intended via frequency_completed IS NOT
-- NULL. Separately, this closes the Query 102 discrepancy: customer
-- 17961 has 100 completed orders (£28.67 average order value), not
-- ~120 (~£24) as originally framed. Per the append-only rule, this
-- should be added as a notation back at Query 102's own write-up,
-- not a silent edit. The 1,619 rows with NULLs in interval/other
-- fields remain an open, undocumented pattern — worth a dedicated
-- check before the correlation heatmap or 3D cube treats them as
-- complete rows.