-- Query 160_stock_behavior_fields_spotcheck

-- WHAT: Pulls stock code 23166's full row from the assembled
--       stock_behavior_fields table, to confirm every field matches
--       the values already independently verified across queries
--       153-158.
-- WHY: Stock code 23166 was already independently confirmed at Query
--      155 (monetary_gross £81,985.11, monetary_net £4,505.47, gap
--      traced to customer 12346's cancelled bulk order from Query 111).
--      Confirming the same values carry through correctly in the final
--      joined table, rather than assuming the join logic preserved
--      every component correctly -- mirrors the customer-side spot-
--      check pattern established at Query 95.

SELECT * FROM uk_retail.stock_behavior_fields
WHERE stock_code = '23166';

-- RESULT (verified against pasted output): one row returned for stock
-- code 23166, all ten fields confirmed exactly against their
-- individually-verified source queries: recency_days=0 (Query 153),
-- frequency_completed=247/cancellation_count=10 (Query 154),
-- monetary_gross=£81,985.11/monetary_net=£4,505.47 (Query 155),
-- avg_interval_whole_day=0.9/avg_interval_fractional_day=1.32 (Query
-- 156), distinct_customers=138 (Query 157), order_return_rate_pct=3.9/
-- line_item_return_rate_pct=3.2 (Query 158). Zero discrepancies across
-- all six component fields.

-- CONFIRMED FINDING: The six-way LEFT JOIN assembly in Query 159
-- correctly preserves every source field with no corruption or
-- misalignment. stock_behavior_fields is fully trustworthy for the
-- remaining sprint work. Phase 2 (build the stock-side RFM parallel) is
-- complete. Ready for Phase 3 (the variant-vs-family grain decision).

-- [REVISION -- this spot-check validated the WRONG table] This query
-- was run against stock_behavior_fields as it existed BEFORE the
-- full_transactions double-counting bug (confirmed and fixed at Queries
-- 151b/151c/151d) was corrected and the table was rebuilt (Query 159's
-- reconstruction, run and confirmed July 31, 2026). The values in this
-- CSV (monetary_gross=81985.11, monetary_net=4505.47,
-- line_item_return_rate_pct=3.2) are the OLD buggy figures, matching
-- Query 155's ORIGINAL pre-fix output exactly, not its corrected rerun.
-- This spot-check's own stated purpose -- confirming the join preserves
-- verified values correctly -- is not satisfied by this result, because
-- the source table it validated no longer exists in this form.
--
-- Expected values once rerun against the rebuilt stock_behavior_fields,
-- based on each field's individually-confirmed status: recency_days=0,
-- frequency_completed=247, cancellation_count=10 (all three unaffected
-- by the bug, per Queries 153/154), monetary_gross=81700.92,
-- monetary_net=4221.28 (corrected, per Query 155's rerun),
-- avg_interval_whole_day=0.9, avg_interval_fractional_day=1.32
-- (unaffected, per Query 156), distinct_customers=138 (unaffected,
-- per Query 157), order_return_rate_pct=3.9 (unaffected),
-- line_item_return_rate_pct=3.8 (corrected, was 3.2, per Query 158's
-- rerun). This query needs to be re-run against the current table and
-- the actual output compared against this expectation before Phase 2
-- can be re-confirmed complete.

-- [CONFIRMED via rerun against the rebuilt table] Actual result: 23166,
-- recency_days=0, frequency_completed=247, frequency_all=257,
-- cancellation_count=10, monetary_gross=81700.92, monetary_net=4221.28,
-- avg_interval_whole_day=0.9, avg_interval_fractional_day=1.32,
-- distinct_customers=138, order_return_rate_pct=3.9,
-- line_item_return_rate_pct=3.8. Every field matches the expected
-- corrected values exactly, including frequency_all=257 (not listed in
-- the expected table above -- an omission there, not a discrepancy
-- here, since it's internally consistent: 257 - 247 = 10, matching
-- cancellation_count). Independently reproduced on a second run of this
-- exact query, same session -- identical result across both
-- executions, confirming this isn't a session-state artifact.

-- CONFIRMED FINDING (supersedes the version above): The six-way LEFT
-- JOIN assembly in the rebuilt Query 159 correctly preserves every
-- source field with no corruption or misalignment, verified against the
-- CORRECTED full_transactions this time. stock_behavior_fields is now
-- genuinely trustworthy -- both the join logic and the underlying data
-- feeding it are confirmed clean. Phase 2 (build the stock-side RFM
-- parallel) is complete, for real this time. Ready for Phase 3 (the
-- variant-vs-family grain decision) and, more urgently, ready to
-- re-verify Chapter Five's headline findings (572 Overdue Restock / 93
-- Seasonal Dormant / 108 Dead Stock) against this corrected table.