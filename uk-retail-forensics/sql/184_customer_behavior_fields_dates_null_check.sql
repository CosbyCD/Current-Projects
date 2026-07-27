-- Query 184_customer_behavior_fields_dates_null_check

-- ============================================================
-- WHAT: Confirms zero NULLs in the two new columns added by
--       Query 182 (first_purchase_date, last_order_date) across
--       all 5,875 customers in customer_behavior_fields.
-- WHY: Every other component field in this table (frequency,
--      interval, product diversity, return rate) has documented,
--      expected NULLs for the 23 cancellation-only customers,
--      since those fields are built with an invoice_no NOT LIKE
--      'C%' filter that cancellation-only customers can never
--      satisfy (see Query 94's CONFIRMED FINDING). This check
--      exists specifically to confirm first_purchase_date and
--      last_order_date do NOT inherit that same NULL pattern,
--      since — like the recency CTE they're built alongside —
--      they use an unconditional customer_id-not-null scan with
--      no invoice-type filter, and so should be populated for
--      every customer including the 23 cancellation-only ones.
-- ============================================================
SELECT COUNT(*) FROM uk_retail.customer_behavior_fields
WHERE first_purchase_date IS NULL OR last_order_date IS NULL;

-- RESULT: 0. Run July 26, 2026.

-- CONFIRMED FINDING: first_purchase_date and last_order_date are fully
-- populated across all 5,875 customers, with zero NULLs — including the
-- 23 cancellation-only customers who do carry NULLs in frequency_completed,
-- avg_interval_fractional_day, and the diversity fields. This confirms the
-- two new columns behave as designed: derived from the same unconditional
-- scan as recency_days (Query 94), not from any of the invoice_no NOT LIKE
-- 'C%'-filtered CTEs that produce structural NULLs for cancellation-only
-- customers.