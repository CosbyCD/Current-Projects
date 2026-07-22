-- Query 100_recency_bump_cohort_check

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

-- RESULT: Step 3 output only (Steps 1 and 2 results not provided
-- for this write-up). Monthly breakdown of last-purchase dates for
-- the 350-424 day recency bump: October 2010 = 180 customers,
-- November 2010 = 307 customers, December 2010 = 131 customers.
-- Total = 618 customers, entirely concentrated in a three-month
-- window (Oct-Dec 2010).

-- CONFIRMED FINDING: The 350-424 day recency bump is explained by a
-- concentrated cohort of 618 customers whose last purchase falls
-- entirely within Oct-Dec 2010 — a pre-Christmas seasonal ordering
-- window. This confirms the bump is a real, dateable pattern rather
-- than noise, and gives it a concrete size (618 customers) suitable
-- for a documented Tableau bucket. Note: this write-up corrects the
-- overstated WHY-block claim that Query 99 already "confirmed" this
-- bump as real — Query 99 flagged it as a candidate for follow-up;
-- this query (100) is what actually confirms it.