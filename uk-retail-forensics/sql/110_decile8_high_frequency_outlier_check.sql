-- Query 110_decile8_high_frequency_outlier_check
-- WHAT: Identify the customer(s) driving decile 8's anomalous MAX
--       frequency_completed of 100 (query 108), by pulling full
--       customer-level detail for the monetary_gross range covered by
--       decile 8, ordered by frequency descending, and confirming whether
--       this is a single outlier or a small cluster.
-- WHY: Query 108's decile crosstab showed decile 8 (70th-80th percentile
--      by spend) with a MAX frequency of 100 -- higher than decile 9's
--      MAX of 34, breaking the otherwise-clean ascending pattern across
--      deciles. Confirmed as a distinct outlier from customers 17850 and
--      12346 (query 109), since neither falls in this spend range. Per
--      this project's standing rule, the outlier needs to be identified
--      and characterized before being written up as a finding.

WITH decile AS (
    SELECT
        customer_id,
        recency_days,
        monetary_gross,
        frequency_completed,
        cancellation_count,
        order_return_rate_pct,
        NTILE(10) OVER (ORDER BY monetary_gross) AS monetary_decile
    FROM uk_retail.customer_behavior_fields
    WHERE monetary_gross IS NOT NULL AND frequency_completed IS NOT NULL
)
SELECT
    customer_id,
    recency_days,
    monetary_gross,
    frequency_completed,
    cancellation_count,
    order_return_rate_pct
FROM decile
WHERE monetary_decile = 8
ORDER BY frequency_completed DESC;

-- RESULT (run July 18, 2026):
-- The decile 8 outlier (MAX frequency 100) is customer 17961: recency 20
-- days, monetary_gross £2,866.74, 100 completed orders, 2 cancellations,
-- 2.0% order_return_rate_pct. This is NOT a new outlier -- it is the same
-- customer 17961 already identified and investigated in Chapter Three
-- (surfaced via 3D chart hover, rank 4673 by monetary_gross, flagged for
-- a disproportionately low average order value relative to peers at that
-- spend rank) and documented as closed/resolved in the project handoff:
-- "resolved as a recurring small retailer."
-- No second comparable outlier appears in the remainder of decile 8 --
-- frequency decays smoothly after 17961 (25, 22, 20, 20, 20, ...) with no
-- further anomalous spike.
--
-- CONFIRMED FINDING: The decile-8 frequency outlier flagged in query 108
-- is fully explained by customer 17961, a previously investigated and
-- closed Chapter Three finding, not a new pattern. No further follow-up
-- required. This cross-chapter consistency (the same customer surfacing
-- independently via chart rotation in Chapter Three and via decile
-- crosstab in Chapter Four prep) supports confidence in both findings.

-- [FLAG — unresolved as of July 22, 2026: this query's WHY block
-- characterizes customer 17961 as "resolved as a recurring small
-- retailer." This conflicts with the investigation log's Chapter Three
-- closing summary ("seasonal-reseller pattern") and with Query 102's own
-- verified finding ("NOT a wholesale/reseller pattern... habitual
-- small-basket, low-unit-price purchasing"). Three documents, two
-- conflicting framings. Needs a single reconciled statement before
-- Chapter Four repeats any version of this.]

-- [RESOLUTION — added July 22, 2026: the "recurring small retailer"
-- framing in this query's WHY block, and the investigation log's
-- separate "seasonal-reseller pattern" framing, are both superseded.
-- Query 102's verified order-history pull explicitly found NO evidence
-- of wholesale/reseller behavior (no bulk single-SKU orders) --
-- "reseller" in any form is not supported by the data. "Seasonal" was
-- never tested by any query in this project. Reconciled characterization:
-- customer 17961 is a recurring, high-frequency, small-basket buyer (100
-- completed orders, £28.67 average, £13.65 median, low-unit-price
-- novelty/craft items) -- "recurring" and "small-basket" are confirmed;
-- "retailer/reseller" and "seasonal" are not.
--
-- ANALYST OBSERVATION (Ree Cosby, July 22, 2026, not SQL-confirmed):
-- the frequency, basket size, and craft/novelty product mix (pencils,
-- erasers, trinket boxes) are more consistent with a non-retail personal
-- or project-driven use case than with any resale profile -- candidate
-- readings include a teacher or craft instructor buying classroom
-- supplies, a hobbyist crafter, or a set decorator/prop buyer, among
-- other possibilities. This dataset cannot distinguish between these --
-- clean_transactions has no customer-type, business-name, or
-- purchase-purpose field. Recorded as an open interpretive question for
-- Chapter Four narrative framing, not a confirmed characterization, and
-- not narrowed to a single guess.]