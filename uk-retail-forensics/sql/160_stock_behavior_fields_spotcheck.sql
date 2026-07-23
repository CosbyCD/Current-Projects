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