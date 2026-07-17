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