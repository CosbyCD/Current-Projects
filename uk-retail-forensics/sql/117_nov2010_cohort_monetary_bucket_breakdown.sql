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