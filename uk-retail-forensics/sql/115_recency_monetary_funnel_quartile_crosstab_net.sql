-- Query 115_recency_monetary_funnel_quartile_crosstab_net
-- WHAT: Rerun query 106's recency-quartile-vs-monetary-quartile crosstab,
--       substituting monetary_net for monetary_gross, to test whether the
--       61-customer "lapsed whale" population (recency quartile 4,
--       monetary quartile 4) persists once cancelled orders are excluded
--       from the spend figure.
-- WHY: Per this project's standing both-forks rule (precedent: frequency
--      completed vs. all-orders, whole-day vs. fractional-day interval),
--      a monetary_net version of query 106 should have been built
--      alongside it from the start -- it was not. The gap was only caught
--      after query 111 found that customer 12346's monetary_gross outlier
--      was almost entirely a bulk order cancelled 16 minutes after being
--      placed, and query 112 built the net twin of query 105 in response.
--      This query closes the same gap on 106's side of the funnel
--      investigation. Documented here as a process gap, not corrected
--      retroactively by renumbering -- see queries 111/112 for how it was
--      caught.

WITH quartiled AS (
    SELECT
        customer_id,
        recency_days,
        monetary_net,
        NTILE(4) OVER (ORDER BY recency_days) AS recency_quartile,
        NTILE(4) OVER (ORDER BY monetary_net) AS monetary_quartile
    FROM uk_retail.customer_behavior_fields
    WHERE recency_days IS NOT NULL AND monetary_net IS NOT NULL
)
SELECT
    recency_quartile,
    monetary_quartile,
    COUNT(*) AS customer_count
FROM quartiled
GROUP BY recency_quartile, monetary_quartile
ORDER BY recency_quartile, monetary_quartile;

-- RESULT (run July 18, 2026):
-- Recency quartile 4 (most lapsed) x Monetary quartile 4 (highest spend,
-- net) = 59 customers -- versus 61 customers in the gross version (query
-- 106). A drop of only 2, not the sharp shrinkage the gross/net funnel
-- recheck (query 112) might have suggested was possible.
-- Full crosstab, net-based:
--   RQ1: 117 / 241 / 377 / 728
--   RQ2: 220 / 345 / 434 / 464
--   RQ3: 392 / 437 / 422 / 212
--   RQ4: 734 / 440 / 230 / 59
-- The overall shape closely mirrors query 106's gross-based crosstab --
-- same monotonic decline pattern, same general quartile distribution.
--
-- CONFIRMED FINDING: The lapsed-whale population is NOT meaningfully
-- reduced by switching from monetary_gross to monetary_net at the
-- quartile level (61 -> 59 customers, a 3% change). This differs from
-- query 112's fixed-bucket MAX-value view, where several buckets showed
-- large individual-customer swings (e.g. -52% in the 200-249 day
-- bucket). The two forks agree at the aggregate/population level (the
-- funnel holds, a real lapsed-whale tail exists either way) but the
-- MAX-value view is more sensitive to individual cancelled-order
-- artifacts than the quartile-count view -- both are legitimate and
-- complementary, not contradictory, readings of the same underlying
-- data. Cancellation artifacts like customer 12346 (query 111) skew
-- individual MAX figures without meaningfully changing the size of the
-- lapsed-whale population as a whole.
--
-- [REVISION NOTICE — added by Query 127_whale_definition_discrepancy_check,
-- run July 18, 2026: the NTILE(4) OVER (ORDER BY recency_days) window
-- function used in this query is non-deterministic at tied boundary
-- values in the absence of a secondary sort key. This means the exact
-- 59-customer count and specific quartile membership reported here may
-- not be perfectly reproducible if this query is rerun. Superseded for
-- all Chapter Four production use by the fixed dual-threshold definition
-- established in Query 122 (recency_days >= 377 AND monetary_net >=
-- 2180.28, yielding 58 customers) and reconstructed directly in Query 126
-- — see those queries and Query 127 for the full finding. This query's
-- role as an independent confirmation fork remains valid and unchanged;
-- only its use as an exact, reproducible boundary definition is
-- superseded.]