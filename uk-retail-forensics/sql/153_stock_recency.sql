-- Query 153_stock_recency

-- WHAT: Builds the first field of stock_behavior_fields -- recency_days
--       per stock_code, defined as days between the dataset's reference
--       date (MAX(invoice_date) across all of full_transactions) and
--       each SKU's own most recent invoice_date. Mirrors the customer-
--       side recency definition exactly (Query 45/94): no invoice_no
--       filter, so a SKU's most recent activity of ANY kind (completed
--       or cancelled) counts toward its recency.
-- WHY: First field of the stock-side RFM parallel (Phase 2, step 1).
--      Using the same no-filter definition as the customer side keeps
--      the two frameworks directly comparable and consistent with this
--      project's established recency methodology, rather than
--      introducing a new definition for the stock dimension.

SELECT
    stock_code,
    EXTRACT(DAY FROM (SELECT MAX(invoice_date) FROM uk_retail.full_transactions) - MAX(invoice_date))::INT AS recency_days
FROM uk_retail.full_transactions
GROUP BY stock_code
ORDER BY stock_code;

-- RESULT: 4,734 rows returned, all distinct stock_code values -- no
-- duplicate SKUs, matching the population Query 159 later confirms as
-- the full stock recency count.

-- CONFIRMED FINDING: This query was run against full_transactions
-- before the double-counting bug (confirmed and fixed at Queries
-- 151b/151c/151d) was corrected. Initially reasoned to be unaffected on
-- structural grounds (MAX(invoice_date) is duplicate-insensitive), then
-- independently confirmed by rerunning this exact query against the
-- corrected full_transactions and diffing the two outputs directly:
-- 4,734 rows in both runs, identical stock_code sets, zero value
-- differences across every recency_days figure. Not an assumption --
-- verified.