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