-- Query 128_frequency_spike_percentile_threshold_net
-- WHAT: Find the 90th percentile monetary_net value using
--       PERCENTILE_CONT, to serve as the Chapter Four Tableau threshold
--       for the frequency-spike tier (query 108's finding: frequency
--       spikes sharply in the top decile by spend, not the originally
--       estimated top 15-20%).
-- WHY: Query 127 found that NTILE(4) OVER (ORDER BY ...) is
--      non-deterministic at tied boundary values without a secondary
--      sort key, causing a 59-vs-58 discrepancy in the lapsed-whale
--      definition. Rather than repeat that risk with NTILE(10) for the
--      decile threshold, PERCENTILE_CONT is used instead -- it computes
--      a single interpolated value directly, with no row-partitioning or
--      tie-breaking involved, and is fully deterministic on every run.
--      This also switches to monetary_net for consistency with this
--      project's decision (query 118) to use net as the primary spend
--      metric going forward -- query 108's original finding was based on
--      monetary_gross deciles, so this value will not be identical, only
--      analogous.

SELECT
    PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY monetary_net) AS p90_monetary_net,
    COUNT(*) FILTER (
        WHERE monetary_net >= (
            SELECT PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY monetary_net)
            FROM uk_retail.customer_behavior_fields
            WHERE monetary_net IS NOT NULL
        )
    ) AS customers_at_or_above_p90
FROM uk_retail.customer_behavior_fields
WHERE monetary_net IS NOT NULL;

-- RESULT (run July 18, 2026):
-- P90 monetary_net threshold: £5,224.45
-- Customers at or above this threshold: 586, closely matching the
-- expected ~10% of the ~5,852-customer population (10.0%).
--
-- CONFIRMED FINDING: The 90th-percentile monetary_net threshold is
-- £5,224.45, computed via PERCENTILE_CONT with no tie-breaking ambiguity
-- -- fully deterministic and reproducible on every run, unlike the
-- NTILE-based approach flagged in query 127. This value is analogous to
-- but not identical with query 108's original monetary_gross decile
-- finding, since this uses monetary_net per the project's standing
-- gross-to-net metric decision (query 118). Ready for direct use in the
-- Chapter Four Tableau "frequency spike" tier field.