-- Query 111_customer_12346_order_history_check
-- WHAT: Pull full transaction-level detail for customer 12346 from
--       clean_transactions -- every invoice, line item, quantity, and
--       unit price -- to characterize the £77,352.96 lifetime spend
--       across only 3 completed orders identified in query 109.
-- WHY: Query 109 identified customer 12346 as a monetary outlier (325
--      days recency, only 3 orders, £77,352.96 monetary_gross) sitting
--      in the 300-349 day recency bucket, distinct from the frequency
--      outlier (customer 17850). An extremely high spend concentrated in
--      so few orders needs characterization before being written up --
--      is this a legitimate large wholesale/bulk order, or a data
--      quality artifact (e.g. a duplicated invoice, a decimal/unit error)?

SELECT
    invoice_no,
    invoice_date,
    stock_code,
    description,
    quantity,
    unit_price,
    (quantity * unit_price) AS line_total
FROM uk_retail.clean_transactions
WHERE customer_id = '12346'
ORDER BY invoice_date, invoice_no;

-- RESULT (run July 18, 2026):
-- Customer 12346's transaction history consists of three real events:
--   - Invoice 499763 (2010-03-02): parasols/umbrella, £27.05
--   - Invoice 513774 (2010-06-28): 18 doormat variants, £142.31
--   - Invoice 541431 (2011-01-18, 10:01am): 74,215 units of "MEDIUM
--     CERAMIC TOP STORAGE JAR" at £1.04 = £77,183.60
--   - Invoice C541433 (2011-01-18, 10:17am): full cancellation of the
--     same line, -74,215 units = -£77,183.60
-- The bulk storage-jar order was cancelled 16 minutes after being placed,
-- same day, same item, same quantity. Actual net spend across this
-- customer's real activity is approximately £169.36 (parasols + doormats
-- only) -- not the £77,352.96 monetary_gross figure used in queries 105,
-- 106, and 109.
--
-- CONFIRMED FINDING: The "lapsed whale" outlier surfaced in queries
-- 105/106/109 is NOT a genuine high-value dormant customer -- it is a
-- monetary_gross artifact caused by a bulk order that was placed and
-- fully cancelled within the same 16-minute window. This customer's real
-- spend (~£169) places them nowhere near the top monetary quartile once
-- cancelled orders are excluded. This calls into question whether other
-- MAX-monetary_gross outliers in queries 105/109 are similarly inflated
-- by cancelled bulk orders rather than genuine spend -- see query 112,
-- which reruns the funnel check on monetary_net to test this directly.

-- [CORRECTION — verified July 22, 2026: invoice 513774 is described as
-- "18 doormat variants" in the RESULT block. Actual line count is 19
-- (confirmed by direct count against the pasted CSV). The £142.31 total
-- is correct and unaffected (19 x £7.49 = £142.31).]