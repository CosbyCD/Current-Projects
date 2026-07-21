-- Query 135_attempt_count_by_cohort_check

-- WHAT: Groups all 5,875 customers (converted and never-converted) by
-- first-transaction quarter and computes count, average attempt_count,
-- median attempt_count, and max attempt_count per cohort. Built to test
-- whether the high-attempt "tower" observed in the Query 134 exhibit
-- rotation (concentrated in early-2009/2010 cohorts, ~500-700 days recency)
-- reflects a genuine cohort-wide tenure effect or is driven by a small
-- number of extreme outliers like the 466-attempt customer already
-- surfaced in this dataset.

-- WHY: Per this project's standing rule, nothing becomes a documented
-- finding on the strength of a chart rotation alone. The exhibit built in
-- Query 134 visually suggested that customers with early first-transaction
-- dates carry higher attempt counts than more recent cohorts -- a
-- reasonable tenure-effect hypothesis, but unconfirmed. Comparing AVERAGE
-- against MEDIAN per cohort is the direct test: if the average is pulled
-- well above the median in the early cohorts, the "tower" is a small number
-- of outliers, not a genuine population-wide pattern; if average and median
-- move together, the effect is real and broad-based.

WITH customer_span AS (
    SELECT
        customer_id,
        MIN(invoice_date) AS first_transaction_date,
        COUNT(DISTINCT invoice_no) AS attempt_count
    FROM uk_retail.clean_transactions
    GROUP BY customer_id
)
SELECT
    DATE_TRUNC('quarter', cs.first_transaction_date) AS cohort_quarter,
    COUNT(*) AS customer_count,
    ROUND(AVG(cs.attempt_count), 2) AS avg_attempt_count,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cs.attempt_count) AS median_attempt_count,
    MAX(cs.attempt_count) AS max_attempt_count,
    ROUND(AVG(cbf.recency_days), 1) AS avg_recency_days
FROM uk_retail.customer_behavior_fields cbf
JOIN customer_span cs ON cs.customer_id = cbf.customer_id
GROUP BY DATE_TRUNC('quarter', cs.first_transaction_date)
ORDER BY cohort_quarter;

-- RESULT (Query 135):
cohort_quarter | customer_count | avg_attempt | median_attempt | max_attempt | avg_recency
2009-10        | 1040          | 18.65       | 10             | 466        | 194.6
2010-01        | 1146          | 8.28        | 6              | 78         | 256.4
2010-04        | 803           | 5.37        | 4              | 42         | 275.3
2010-07        | 579           | 5.48        | 3              | 60         | 245.2
2010-10        | 776           | 3.76        | 2              | 38         | 223.5
2011-01        | 374           | 4.14        | 2              | 41         | 163.1
2011-04        | 322           | 3.51        | 2              | 33         | 116.2
2011-07        | 395           | 2.82        | 2              | 18         | 58.9
2011-10        | 440           | 1.82        | 1              | 11         | 27.2

-- CONFIRMED FINDING: The tower is real, not an artifact of a few outliers.
-- Median attempt_count declines steadily and almost monotonically from
-- earliest to latest cohort (10 -> 6 -> 4 -> 3 -> 2 -> 2 -> 2 -> 2 -> 1),
-- confirming a genuine population-wide tenure effect: customers who joined
-- earlier have had more time to accumulate attempts, and this holds at the
-- median, not just the mean. The average/median ratio stays roughly
-- constant across cohorts (~1.3-2x) rather than widening in the earliest
-- quarter, meaning the right-skew (a few high-attempt customers like the
-- 466-attempt case in Q4 2009) is a stable background feature of every
-- cohort, not something specifically inflating the earliest one. The
-- Query 134 exhibit's visual "tower" is a legitimate finding: it reflects
-- real tenure-driven accumulation, correctly visible in the rotation, now
-- confirmed in SQL per this project's standard.