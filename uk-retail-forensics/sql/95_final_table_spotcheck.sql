-- Query 95_final_table_spotcheck

-- ============================================================
-- VERIFICATION: Final customer_behavior_fields table — spot-check
-- WHAT: Pulls customer 13468's full row from the assembled
--       final table, to confirm every field matches the values
--       already independently verified across this chapter.
-- WHY: Customer 13468 was already spot-checked individually for
--      recency (query 48: recency_days = 1). Confirming the
--      same value carries through correctly in the final
--      joined table, rather than assuming the join logic
--      preserved every component correctly.
-- ============================================================
SELECT * FROM uk_retail.customer_behavior_fields
WHERE customer_id = '13468';

-- RESULT: One row returned for customer 13468:
-- recency_days=1, frequency_completed=72, cancellation_count=14,
-- monetary_gross=12793.28, monetary_net=12518.01,
-- avg_interval_whole_day=9.9, avg_interval_fractional_day=10.35,
-- distinct_variants_purchased=290, distinct_families_purchased=278,
-- order_return_rate_pct=16.3, line_item_return_rate_pct=2.9.

-- CONFIRMED FINDING: recency_days=1 matches the previously confirmed
-- Query 48 spot-check value, verifying that the recency component
-- carried through the six-way LEFT JOIN into the final table
-- without corruption for this customer. The remaining ten fields in
-- this row (frequency, monetary, interval, diversity, return rate)
-- are recorded here as the table's actual output but are not
-- independently cross-referenced against a prior single-customer
-- spot-check in this write-up, since none is cited in the WHAT/WHY
-- beyond recency — per the no-forward-citation and no-fabrication
-- rules, this finding confirms only what the data in hand supports.
-- If a separate prior spot-check exists for 13468 on the other
-- fields, it should be cited backward explicitly in a future entry
-- rather than assumed here.