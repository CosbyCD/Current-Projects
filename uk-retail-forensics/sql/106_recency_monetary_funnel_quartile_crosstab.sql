-- Query 106_recency_monetary_funnel_quartile_crosstab
-- WHAT: Cross-tabulate recency quartile against monetary_gross quartile,
--       to test the same "recency-monetary funnel" claim using the data's
--       own distribution rather than an arbitrary fixed day-cutoff.
-- WHY: Query 105 tests the funnel with a round-number bucket width, which
--      risks imposing a boundary the data doesn't actually have. This is
--      the second, independently-derived fork on the same finding — per
--      the project's standing rule, both are built and kept side by side
--      rather than settling on one threshold definition (precedent: gross
--      vs. net monetary, whole-day vs. fractional-day interval).

WITH quartiled AS (
    SELECT
        customer_id,
        recency_days,
        monetary_gross,
        NTILE(4) OVER (ORDER BY recency_days) AS recency_quartile,
        NTILE(4) OVER (ORDER BY monetary_gross) AS monetary_quartile
    FROM uk_retail.customer_behavior_fields
    WHERE recency_days IS NOT NULL AND monetary_gross IS NOT NULL
)
SELECT
    recency_quartile,
    monetary_quartile,
    COUNT(*) AS customer_count
FROM quartiled
GROUP BY recency_quartile, monetary_quartile
ORDER BY recency_quartile, monetary_quartile;

-- RESULT (run July 18, 2026):
-- Of the top monetary quartile (1,463 highest-spend customers): 729 (49.8%)
-- fall in the most-recent recency quartile, 458 (31.3%) in the second,
-- tapering to 215 (14.7%) and 61 (4.2%) in the most-lapsed recency
-- quartile. A clean, monotonic decline — recency and monetary value move
-- together as a general tendency.
--
-- However, this directly contradicts the ABSOLUTE version of the original
-- claim ("no customer past ~300-400 days ever reaches high monetary
-- value"): 61 customers sit in BOTH the highest monetary quartile and the
-- most-lapsed recency quartile. That is not zero.
--
-- CONFIRMED FINDING (revised from Chapter Three's original visual claim,
-- agrees with query 105's independently-derived fork):
-- Average customer spend declines steadily as recency increases, but a
-- small population of high-value outliers ("lapsed whales") exists at
-- every recency level. The funnel governs the typical customer; it does
-- not govern the tail. The 61 lapsed-whale customers identified here are a
-- legitimate follow-up investigation thread (wholesale/reseller one-off
-- large orders vs. data quality issue vs. genuine retention-target
-- segment) — not yet investigated as of this query's close.
--
-- [REVISION NOTICE — added by Query 127_whale_definition_discrepancy_check,
-- run July 18, 2026: the NTILE(4) OVER (ORDER BY recency_days) window
-- function used in this query is non-deterministic at tied boundary
-- values in the absence of a secondary sort key (e.g. ORDER BY
-- recency_days, customer_id). This means the exact 61-customer count and
-- specific quartile membership reported here may not be perfectly
-- reproducible if this query is rerun. Superseded for all Chapter Four
-- production use by the fixed dual-threshold definition established in
-- Query 122 (recency_days >= 377 AND monetary_net >= 2180.28, yielding 58
-- customers) and reconstructed directly in Query 126 — see those queries
-- and Query 127 for the full finding. This query's role as the original
-- discovery mechanism for the lapsed-whale population remains valid and
-- unchanged; only its use as an exact, reproducible boundary definition
-- is superseded.]