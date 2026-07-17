-- ============================================================
-- VERIFICATION: Recency bump cohort — last purchase date check
-- WHAT: Derives last_invoice_date per customer from
--       clean_transactions (not stored directly on
--       customer_behavior_fields), joins it to customers in the
--       350-424 day recency bump, and summarizes by month to
--       test whether the bump reflects an Oct-Dec 2010
--       pre-Christmas ordering cohort.
-- WHY: Query 99 confirmed the 350-424 bump is real, not an
--      artifact. This tests the specific hypothesis before it
--      goes into the Tableau workbook as a documented bucket.
-- ============================================================

-- Step 1: confirm the reference date recency was calculated against
SELECT MAX(invoice_date) AS reference_date
FROM uk_retail.clean_transactions;

-- Step 2: derive last purchase date per customer, then filter to the bump bucket
WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(invoice_date) AS last_invoice_date
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
)
SELECT
    cbf.customer_id,
    cbf.recency_days,
    lp.last_invoice_date
FROM uk_retail.customer_behavior_fields cbf
JOIN last_purchase lp ON lp.customer_id = cbf.customer_id
WHERE cbf.recency_days BETWEEN 350 AND 424
ORDER BY lp.last_invoice_date;

-- Step 3: summarize by month to see the shape of the cluster at a glance
WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(invoice_date) AS last_invoice_date
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
)
SELECT
    DATE_TRUNC('month', lp.last_invoice_date) AS purchase_month,
    COUNT(*) AS customer_count
FROM uk_retail.customer_behavior_fields cbf
JOIN last_purchase lp ON lp.customer_id = cbf.customer_id
WHERE cbf.recency_days BETWEEN 350 AND 424
GROUP BY DATE_TRUNC('month', lp.last_invoice_date)
ORDER BY purchase_month;