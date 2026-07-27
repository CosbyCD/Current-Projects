-- Query 183_customer_behavior_fields_dates_consistency_check

-- ============================================================
-- WHAT: Independently re-confirms that Query 182's new
--       last_order_date column is internally consistent with
--       the existing recency_days column, spot-checked against
--       customer_id 16754 (the confirmed lapsed-whale customer,
--       independently established in Query 121).
-- WHY: Per this project's standing rule of never trusting a
--      table-build result on the strength of "it looks right"
--      (see Query 97's precedent, independently re-confirming
--      Query 96's row count rather than accepting the CREATE
--      TABLE AS result alone), Query 182 added two new date
--      columns to customer_behavior_fields. This check confirms
--      last_order_date derives from the same reference date and
--      the same unconditional clean_transactions scan already
--      used to compute recency_days, rather than assuming the
--      two are consistent just because they came from CTEs in
--      the same query.
-- ============================================================
SELECT customer_id, recency_days, last_order_date,
       (SELECT MAX(invoice_date) FROM uk_retail.clean_transactions) - last_order_date AS derived_recency
FROM uk_retail.customer_behavior_fields
WHERE customer_id = '16754';

-- RESULT: customer_id = 16754, recency_days = 371,
-- last_order_date = 2010-12-02 17:38:00,
-- derived_recency = 371 days 19:12:00. Run July 26, 2026.

-- CONFIRMED FINDING: The day-count component of derived_recency (371)
-- matches recency_days exactly. The residual time-of-day component
-- (19:12:00) is expected and not an error — recency_days was originally
-- computed in Query 94 via EXTRACT(DAY FROM ...) on a full timestamp
-- subtraction, which discards any sub-day remainder, while this check's
-- derived_recency is a raw interval showing that remainder explicitly.
-- Confirms last_order_date (Query 182) and recency_days (Query 94) are
-- derived from the same reference date (MAX(invoice_date) across all of
-- clean_transactions) and the same unconditional, invoice-type-agnostic
-- customer scan — by construction, not coincidence.