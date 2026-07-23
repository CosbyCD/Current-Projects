-- Query 117_nov2010_cohort_monetary_bucket_breakdown
-- WHAT: Bucket the Nov 2010 cohort (618 customers, recency_days BETWEEN
--       350 AND 424) by monetary_gross range, to show the shape of the
--       spend distribution directly rather than only summary statistics.
-- WHY: Query 114 established summary statistics (min/max/avg/median) for
--      this cohort's spend, showing a right-skewed distribution (average
--      pulled well above median). This query was originally stacked
--      inside 114 as a second SELECT statement and has been split out as
--      its own separate query, per the project's one-result-per-query
--      standard.

SELECT
    CASE
        WHEN monetary_gross < 100 THEN '< £100'
        WHEN monetary_gross < 500 THEN '£100-499'
        WHEN monetary_gross < 1000 THEN '£500-999'
        WHEN monetary_gross < 5000 THEN '£1,000-4,999'
        ELSE '£5,000+'
    END AS monetary_bucket,
    COUNT(*) AS customer_count
FROM uk_retail.customer_behavior_fields
WHERE recency_days BETWEEN 350 AND 424
GROUP BY 1
ORDER BY MIN(monetary_gross);

-- RESULT (run July 18, 2026):
-- < £100:         30 customers (4.9%)
-- £100-499:      292 customers (47.2%)
-- £500-999:      146 customers (23.6%)
-- £1,000-4,999:  140 customers (22.7%)
-- £5,000+:        10 customers (1.6%)
-- 70.9% of the cohort (438 customers) falls in the £100-999 range,
-- consistent with modest gift-shop-scale purchases. A real tail of 140
-- customers (22.7%) in the £1,000-4,999 range and 10 customers (1.6%)
-- above £5,000 confirms the right-skew seen in query 114's summary
-- statistics.
--
-- CONFIRMED FINDING: The Nov 2010 cohort's spend distribution supports
-- the original small-retailer-stocking-for-Christmas hypothesis (query
-- 100) for the bulk of the cohort -- most spend looks like modest shop
-- restocking, not large wholesale -- but with a real minority (23.3% at
-- £1,000+) doing heavier stocking orders, and a small tail (10
-- customers) that may include cancelled-order artifacts similar to
-- customer 12346. That tail is not yet individually characterized.

-- [CORRECTION — verified July 22, 2026: the CONFIRMED FINDING states
-- "23.3% at £1,000+." Actual figure is 24.3% (140+10=150 customers,
-- 150/618 = 24.3%). One-percentage-point arithmetic error.]

-- [REVISION — added per Query 141_nov2010_cohort_high_spend_tail_list,
-- run July 22, 2026: the £5,000+ bucket count of 10 customers reported
-- above is INCORRECT. Direct pull of the actual customer list (Query
-- 141) returns only 7 customers. The other 3 (16995, 13353, 17755) are
-- never-converted customers with NULL monetary_gross, miscategorized
-- into this bucket because the CASE statement above has no explicit
-- NULL branch -- "WHEN monetary_gross < 5000" evaluates to NULL (not
-- TRUE) for a NULL input, so all three silently fell through to the
-- catch-all ELSE '£5,000+' branch. This is the same class of
-- NULL-fallthrough bug independently diagnosed for Tableau at Query
-- 130. CORRECTED bucket count: £5,000+ = 7 customers, not 10.
--
-- DENOMINATOR DECISION: going forward, all percentages in this cohort
-- breakdown use 615 (the 618-customer cohort MINUS the 3 never-converted
-- customers with no spend to bucket) as the base, NOT 618. This matches
-- the precedent set at Query 130, where never-converted customers are
-- excluded from spend-based tiering entirely rather than being folded
-- into whichever bucket a NULL happens to satisfy by default -- treating
-- "no spend" as its own category, not as a silent member of an unrelated
-- spend tier. CORRECTED percentages against the 615 base: £5,000+ =
-- 7/615 = 1.14%; £1,000-4,999 = 140/615 = 22.76%; combined £1,000+ tail
-- = 147/615 = 23.9% (superseding the earlier 24.3%/150-618 correction
-- noted elsewhere on this file). The other three buckets (< £100,
-- £100-499, £500-999) were never affected by the NULL bug and should
-- also be re-expressed against 615 for internal consistency:
-- < £100 = 30/615 = 4.9% (unchanged at this precision); £100-499 =
-- 292/615 = 47.5%; £500-999 = 146/615 = 23.7%. All 7 genuine £5,000+
-- customers have since been individually characterized (queries 121,
-- 142-147) -- all confirmed as genuine spend, no artifacts.]