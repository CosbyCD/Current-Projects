-- Query 54_monetary_gross

-- ============================================================
-- CHAPTER TWO, FIELD 3: Monetary Value — gross (completed only)
-- WHAT: Sums quantity × unit_price for each customer, counting
--       only completed (non-cancelled) transaction lines.
-- WHY: First of two monetary value definitions, following the
--      same both-sides practice established with frequency.
--      Gross reflects total purchase value before accounting
--      for any later cancellations/returns.
-- ============================================================
SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price)::NUMERIC, 2) AS monetary_gross
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
AND invoice_no NOT LIKE 'C%'
GROUP BY customer_id
ORDER BY monetary_gross DESC;

-- RESULT: Top customer is 18102 at $580,987.04, matching the value
-- cited in the investigation log exactly. 5,880 rows returned -- the
-- same row count as Query 50 (frequency_completed_only), consistent
-- with both queries filtering on the identical invoice_no NOT LIKE
-- 'C%' condition and covering the same customer population (all
-- customers excluding the 61 with zero completed orders). Two
-- customers at the bottom of the sort, 14827 and 14103, show
-- monetary_gross = 0.00 -- distinct from the all-cancelled-customer
-- exclusion pattern, since these two DO have at least one completed
-- order; that order's line items simply sum to exactly zero (a
-- zero-price line within an otherwise legitimate completed
-- transaction).

-- CONFIRMED FINDING: Monetary Value (gross, completed-only) built
-- successfully, top customer confirmed against the log. Shares the
-- same 5,880-row population as Query 50's frequency field, for the
-- same reason -- both are filtered to completed orders only. The two
-- zero-value customers (14827, 14103) are a minor edge case worth
-- tracking forward: they will need the same scrutiny given to zero-
-- price rows earlier in this project (Queries 26-28) if monetary_gross
-- is ever used as a denominator or filter condition, since a
-- legitimate completed-order customer with $0 gross value could
-- produce unexpected results (e.g. division by zero, or false
-- inclusion/exclusion) in downstream calculations depending on how
-- it's used.