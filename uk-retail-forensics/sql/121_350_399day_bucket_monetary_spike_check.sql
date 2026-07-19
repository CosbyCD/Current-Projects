-- Query 121_350_399day_bucket_monetary_spike_check
-- WHAT: Pull every customer in the 350-399 day recency bucket, with
--       monetary_gross, monetary_net, frequency_completed, and
--       cancellation_count, sorted by monetary_gross descending, to
--       identify which customer(s) drive the £65,500.07 MAX figure
--       first surfaced in query 105 and left unexamined through queries
--       112 and 114.
-- WHY: Query 105 found MAX monetary_gross of £65,500.07 in this bucket
--      but it was never individually traced to a customer, unlike the
--      other outlier buckets in this range (300-349 days/customer 12346,
--      query 111; 200-249 days/customer 15749, query 116). Query 114
--      later found the same £65,500.07 figure resurfacing as the Nov
--      2010 cohort's maximum, since that cohort's range (350-424 days)
--      overlaps this bucket -- flagged there as still unverified. This
--      closes that gap using the same pull-the-bucket-and-sort approach
--      used throughout this verification pass.

SELECT
    customer_id,
    recency_days,
    monetary_gross,
    monetary_net,
    (monetary_gross - monetary_net) AS gross_net_gap,
    frequency_completed,
    cancellation_count
FROM uk_retail.customer_behavior_fields
WHERE recency_days BETWEEN 350 AND 399
ORDER BY monetary_gross DESC;

-- RESULT (run July 18, 2026):
-- Customer 16754 is the driver of the £65,500.07 figure: recency 371,
-- monetary_gross £65,500.07, monetary_net £54,692.82, gap £10,807.25
-- (16.5% of gross), 29 completed orders, 5 cancellations.
-- This differs structurally from the cancelled-bulk-order pattern found
-- in customers 12346 and 15749 (query 118): those customers had only
-- 3 orders each with the gap representing 50-100% of gross. Customer
-- 16754 has substantial real order volume (29 completed orders) with a
-- modest gap consistent with ordinary cancellation activity, not a
-- single large cancelled order distorting an otherwise-thin history.
-- Two customers in this bucket (16995, 13353) show NULL monetary/
-- frequency values -- confirmed as part of the 23 never-converted,
-- cancellation-only customers already documented in query 98, not new.
--
-- CONFIRMED FINDING: The £65,500.07 monetary_gross figure (first
-- surfaced in Query 105_recency_monetary_funnel_fixed_bucket_check,
-- resurfaced in Query 114_nov2010_cohort_monetary_distribution_check as
-- the Nov 2010 cohort's maximum) belongs to customer 16754 and is
-- GENUINE spend, not a cancellation artifact -- net monetary of
-- £54,692.82 still places this customer well within the confirmed
-- lapsed-whale population. This closes Open Item 4 from the July 18,
-- 2026 open-items review. Query 114's forward reference to this
-- verification is now resolved.