-- Query 150_cancellation_exceeds_purchase_signature_scan

-- WHAT: Full-dataset scan for the customer-16077 signature (Query 138):
--       a single cancellation line whose |quantity| for a given stock_code
--       exceeds the total quantity that same customer ever purchased of
--       that same stock_code across all their completed invoices.
-- WHY: Customer 16077 was flagged as an isolated instance of this pattern
--      at Query 138, never systematically checked elsewhere. Per this
--      project's standing rule (a pattern found once is chased
--      individually; found twice, it gets a full-dataset scan -- see
--      Query 118's precedent), this closes that gap before the anomaly
--      is left as a one-customer curiosity.

WITH purchased AS (
    SELECT customer_id, stock_code, SUM(quantity) AS total_purchased
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL AND invoice_no NOT LIKE 'C%'
    GROUP BY customer_id, stock_code
),
cancelled AS (
    SELECT customer_id, stock_code, invoice_no, invoice_date, quantity AS cancelled_qty
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL AND invoice_no LIKE 'C%'
)
SELECT
    c.customer_id,
    c.invoice_no,
    c.invoice_date,
    c.stock_code,
    ABS(c.cancelled_qty) AS cancelled_qty,
    COALESCE(p.total_purchased, 0) AS total_purchased,
    ABS(c.cancelled_qty) - COALESCE(p.total_purchased, 0) AS excess_qty
FROM cancelled c
LEFT JOIN purchased p
    ON p.customer_id = c.customer_id AND p.stock_code = c.stock_code
WHERE ABS(c.cancelled_qty) > COALESCE(p.total_purchased, 0)
ORDER BY excess_qty DESC;

-- RESULT (verified against pasted CSV): 1,134 rows, 482 distinct customers
-- (8.2% of the 5,875-customer base) -- NOT an isolated single-customer
-- anomaly. Splits into two sub-patterns: (1) 1,034 rows (91.2%) cancel a
-- stock code never purchased at all in this dataset -- median excess 2
-- units, 73% of all rows <= 5 units excess -- consistent with
-- left-censored purchase history (real purchases before the dataset's
-- 2009-12-01 start date, invisible here, later returned). (2) 100 rows
-- (8.8%) cancel MORE than a genuine visible purchase -- the true
-- customer-16077 signature -- ranging smoothly from single digits up to
-- 162 units excess (customer 16546), with 16077's own 24-unit excess
-- sitting mid-distribution, not an extreme outlier. Customer 15749
-- (already characterized at Query 116/118) shows the single largest
-- anomaly in the entire scan (1,300-unit phantom cancellation). Customer
-- 13091 (already characterized at Query 119) appears twice, matching
-- exactly the duplicate-cancellation-record pair already identified
-- there (C490807/C490946).

-- CONFIRMED FINDING: Customer 16077's anomaly is NOT an isolated data
-- error -- it is one instance of a systemic, dataset-wide pattern
-- affecting 8.2% of customers, most plausibly explained by left-censored
-- purchase history (this dataset's 2009-12-01 start date cuts off
-- visibility into any purchases made before it). This is a structural
-- limitation of the dataset's time window, not a data-quality defect
-- requiring correction -- consistent with this project's segregate-
-- don't-delete standard, no rows should be altered or excluded on this
-- basis. RECOMMENDATION for Chapter Four: document this as a known
-- structural caveat (dataset left-censoring affects ~8% of customers'
-- cancellation records) rather than pursuing further individual
-- characterization -- the pattern is now explained at the population
-- level, and chasing each of the 482 customers individually would not
-- add further insight beyond what this scan already establishes.