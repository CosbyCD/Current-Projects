-- Query 87_customer_return_after_cancellation

-- ============================================================
-- FOLLOW-UP: Did customers return after a cancellation?
-- WHAT: For every customer with at least one cancelled order,
--       checks whether they placed any completed order AFTER
--       the date of that cancellation.
-- WHY: A direct, practical question a stakeholder would ask:
--      does a cancellation predict a customer never returning,
--      or do most customers come back anyway? This is a
--      retention/return-rate question, kept separate from
--      Field 4 (order-to-order interval), which measures
--      spacing between orders, not whether a customer returns
--      after a specific event.
-- ============================================================
WITH cancellations AS (
    SELECT customer_id, MAX(invoice_date) AS last_cancellation_date
    FROM uk_retail.clean_transactions
    WHERE customer_id IS NOT NULL
    AND invoice_no LIKE 'C%'
    GROUP BY customer_id
),
returned AS (
    SELECT c.customer_id,
           c.last_cancellation_date,
           EXISTS (
               SELECT 1 FROM uk_retail.clean_transactions t
               WHERE t.customer_id = c.customer_id
               AND t.invoice_no NOT LIKE 'C%'
               AND t.invoice_date > c.last_cancellation_date
           ) AS returned_after_cancellation
    FROM cancellations c
)
SELECT
    returned_after_cancellation,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_customers_with_cancellations
FROM returned
GROUP BY returned_after_cancellation;

-- RESULT: 2,443 total customers had at least one cancellation. Of
-- those, 1,741 (71.3%) placed at least one completed order after
-- their most recent cancellation date; 702 (28.7%) never placed
-- another completed order afterward.

-- CONFIRMED FINDING: A cancellation is not a strong predictor that a
-- customer is lost -- nearly three-quarters of customers who cancel
-- at least once go on to complete another order afterward. This is a
-- standalone, stakeholder-relevant finding, tracked separately from
-- the six core customer_behavior_fields (Recency, Frequency, Monetary
-- Value, Interval, Product Diversity, Return Rate) rather than folded
-- into any of them -- it answers a "does this event predict churn"
-- question, distinct from Field 4's "how far apart are this
-- customer's orders" measurement. Worth flagging as a candidate for
-- its own exhibit or dashboard callout, since "71% of cancellers come
-- back" is a concrete, actionable number a retail stakeholder would
-- likely want surfaced directly.