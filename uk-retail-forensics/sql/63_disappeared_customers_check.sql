-- Query 63_disappeared_customers_check

-- ============================================================
-- VERIFICATION: Customers who disappeared after the amendment
-- WHAT: Identifies exactly which 66 customer_ids existed before
--       the administrative-code amendment (query 59) but no
--       longer appear in the amended clean_transactions.
-- WHY: Confirms the missing customers are legitimately gone
--      because their entire transaction history was
--      administrative activity, not evidence of an error in
--      the amendment itself.
-- ============================================================
SELECT customer_id, COUNT(*) AS admin_rows, ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS total_admin_value
FROM uk_retail.raw_transactions
WHERE customer_id IS NOT NULL
AND stock_code !~ '^[0-9]+[A-Za-z]*$'
AND NULLIF(REGEXP_REPLACE(customer_id, '\.0$', ''), '') NOT IN (
    SELECT DISTINCT customer_id FROM uk_retail.clean_transactions WHERE customer_id IS NOT NULL
)
GROUP BY customer_id
ORDER BY admin_rows DESC;

-- RESULT: Exactly 66 customer_ids returned, confirming the population
-- drop precisely. Customer 17846 confirmed at +$2,033.10 (1 admin
-- row), matching the log's cited example of a positive-dollar
-- administrative credit exactly. Several rows here connect directly to
-- earlier fields in this project: all four customers Query 56 found
-- showing an exact negative-mirror pattern (12918 at -$10,953.50,
-- 14802 at -$1,502.98, 15802 at -$451.42, 13290 at -$208.63) are
-- confirmed among these 66 -- their entire recorded "purchase" history
-- was administrative noise, which explains why Query 57's investigation
-- of customer 12918 found nothing but "Manual" stock-code entries: they
-- were never a real customer at all. Customer 17399, the most negative
-- monetary_net value in the entire Query 55 result (-$25,111.09), is
-- also confirmed here with a single $-25,111.09 administrative row --
-- the most extreme net-negative figure in the dataset belonged to a
-- customer whose only "activity" was one large administrative entry,
-- not genuine cancellation behavior. Also resolved: the two zero-value
-- completed-order customers flagged as an open edge case back in Query
-- 54 (14103, 14827) are both confirmed here, each with exactly one
-- admin row valued at $0.00 -- their $0.00 "completed order" was itself
-- an administrative entry, not a real product purchase, fully
-- explaining that earlier flag.

-- CONFIRMED FINDING: All 66 disappeared customers are confirmed
-- legitimately removed -- every one has administrative-code activity
-- as their entire transaction history, with no genuine product
-- purchases. Not every customer had a negative total (17846 at
-- +$2,033.10 stands out as a positive administrative credit), but the
-- underlying conclusion holds regardless of sign: none of the 66 were
-- real purchasing customers. This closes several open threads from
-- earlier in this retrofit at once: the Query 56/57 exact-mirror
-- pattern is now fully explained as a symptom of administrative-only
-- customers, not a real customer-value anomaly; the Query 55 extreme
-- outlier (17399) is explained the same way; and the Query 54 zero-
-- gross edge cases (14103, 14827) are resolved as administrative rows,
-- not real $0 purchases. Field 1 (Recency) status: rebuilt,
-- re-verified, and finalized against the amended table. Customer count
-- revised from 5,941 to 5,875, with the exact difference identified
-- and explained at the individual customer level, not accepted as a
-- plausible-sounding number.