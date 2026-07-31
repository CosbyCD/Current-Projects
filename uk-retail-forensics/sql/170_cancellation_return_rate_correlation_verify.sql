-- Query 170_cancellation_return_rate_correlation_verify

-- WHAT: Directly computes the Pearson correlation between
--       cancellation_count and order_return_rate_pct, using
--       PostgreSQL's native CORR() aggregate function, over the exact
--       same 5,852-customer population Query 103's correlation heatmap
--       used (frequency_completed IS NOT NULL).
-- WHY: The "moderate 0.41" figure cited in Query 104's WHY block
--      traces back to a correlation heatmap described narratively in
--      the log (Post-Chapter-Three Exploration, following Query 103's
--      full-field export) -- but that heatmap was never itself run as
--      a dedicated, numbered SQL query, and was most likely computed
--      informally (e.g. via pandas .corr() on the exported CSV) rather
--      than verified with a SQL aggregate. This closes that gap
--      properly rather than leaving the figure as an unverified
--      narrative citation.

SELECT
    ROUND(CORR(cancellation_count, order_return_rate_pct)::NUMERIC, 3) AS corr_cancellation_orderreturn,
    ROUND(CORR(cancellation_count, line_item_return_rate_pct)::NUMERIC, 3) AS corr_cancellation_lineitemreturn,
    COUNT(*) AS population_size
FROM uk_retail.customer_behavior_fields
WHERE frequency_completed IS NOT NULL;
-- RESULT: corr_cancellation_orderreturn = 0.410, corr_cancellation_
-- lineitemreturn = 0.225, population_size = 5,852 -- matching Chapter
-- Two's non-null frequency population exactly (5,875 total minus the
-- 23 never-converted customers, per Query 98/99).

-- CONFIRMED FINDING: The "moderate 0.41" figure cited narratively in
-- Query 104's WHY block is now independently confirmed via a proper
-- SQL CORR() aggregate, not just an informal pandas computation --
-- 0.410 exactly, closing that verification gap. A second, previously
-- uncomputed correlation is also surfaced: cancellation_count correlates
-- much more weakly with line_item_return_rate_pct (0.225) than with
-- order_return_rate_pct (0.410) -- consistent with cancellations being
-- counted at the order level in one metric and diluted across many
-- individual line items in the other, rather than a genuinely different
-- underlying relationship. Not related to, and not affected by, the
-- full_transactions double-counting bug (this query is customer-side,
-- entirely outside that bug's scope).