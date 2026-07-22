-- Query 104_high_return_low_frequency_cluster

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

-- RESULT: 788 customers returned. order_return_rate_pct ranges
-- 30.8-80.0 (NOT "20-60%" as the WHY block states — the WHERE
-- clause's own >30 threshold makes anything below 30.1 impossible
-- by construction, so the WHY block's range figure does not match
-- this query's logic). frequency_completed ranges 1-9 (consistent
-- with the <10 filter). cancellation_count ranges 1-10. Within this
-- filtered 788-customer subset, the correlation between
-- order_return_rate_pct and cancellation_count is 0.156 — weak, and
-- notably lower than the "moderate 0.41" figure the WHY block
-- references (though that 0.41 figure was described as coming from
-- a separate full-population correlation matrix, not this filtered
-- subset, so the two numbers aren't strictly measuring the same
-- thing — flagged here rather than treated as a direct
-- contradiction).

-- CONFIRMED FINDING: This is a real, isolable cluster of 788
-- customers combining high return rate (>30%) with low order
-- frequency (<10) — not a sparse tail artifact, consistent with
-- the 3D rotation observation. Within this subset specifically, the
-- weak 0.156 correlation between return rate and cancellation count
-- supports the WHY block's core observation that return rate isn't
-- tightly tracking cancellation count here, even though the
-- specific "20-60%" range figure in the WHY block is incorrect and
-- should not be repeated in the Tableau workbook or exhibit gallery
-- — the correct range for this filter is 30.8-80.0%. Before this
-- becomes a documented Tableau bucket, the full-population 0.41
-- correlation figure this WHY block references should itself be
-- traced to its source query and verified, since it has not been
-- independently confirmed within this retrofit sequence.