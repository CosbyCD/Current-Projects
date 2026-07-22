-- Query 101_recency_bump_cohort_frequency_check

-- ============================================================
-- VERIFICATION: Recency bump cohort — frequency distribution
-- WHAT: Pulls frequency_completed for the 618 customers whose
--       recency_days falls between 350-424 days (the Oct-Dec
--       2010 last-purchase cohort confirmed in query 100), to
--       test whether this cohort skews toward one-time/seasonal
--       buyers or includes regulars who simply didn't reorder
--       after that season.
-- WHY: Confirms whether the Nov 2010 stocking pattern represents
--      genuine seasonal-only buyers (low frequency) or lost
--      repeat customers (moderate-to-high frequency who then
--      churned) — changes how this bucket gets framed in the
--      Tableau workbook.
-- ============================================================
WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(invoice_date) AS last_invoice_date
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
),
bumped AS (
    SELECT
        cbf.customer_id,
        cbf.frequency_completed,
        CASE
            WHEN cbf.frequency_completed = 1 THEN '1) 1 order'
            WHEN cbf.frequency_completed BETWEEN 2 AND 5 THEN '2) 2-5 orders'
            WHEN cbf.frequency_completed BETWEEN 6 AND 15 THEN '3) 6-15 orders'
            ELSE '4) 16+ orders'
        END AS frequency_bucket
    FROM uk_retail.customer_behavior_fields cbf
    JOIN last_purchase lp ON lp.customer_id = cbf.customer_id
    WHERE cbf.recency_days BETWEEN 350 AND 424
)
SELECT
    frequency_bucket,
    COUNT(*) AS customer_count
FROM bumped
GROUP BY frequency_bucket
ORDER BY frequency_bucket;

-- RESULT: 1 order = 259 customers, 2-5 orders = 306, 6-15 orders =
-- 45, 16+ orders = 8. Sum = 618, matching the Query 100 cohort size
-- exactly. Combined, 1-5 orders = 565 customers = 91.4% of the
-- cohort. Only 53 customers (8.6%) placed 6 or more orders before
-- their last purchase fell in the Oct-Dec 2010 window.

-- CONFIRMED FINDING: The 618-customer Oct-Dec 2010 recency-bump
-- cohort skews overwhelmingly toward low-frequency buyers — 91.4%
-- placed 5 or fewer orders total. This supports framing the bucket
-- as a genuine seasonal-acquisition cohort (customers who came in
-- for a pre-Christmas purchase and largely didn't return) rather
-- than as lost regulars who churned after an established buying
-- pattern. The 53 customers with 6+ orders (8.6%) are a minority
-- worth flagging separately if the Tableau workbook wants to
-- distinguish "true seasonal one-and-done" from "moderate regulars
-- who happened to stop in this window" within the same bucket.