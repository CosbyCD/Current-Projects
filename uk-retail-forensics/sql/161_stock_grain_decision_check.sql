-- Query 161_stock_grain_decision_check

-- WHAT: Compares the variant-level SKU count (stock_code, 4,734 -- the
--       grain stock_behavior_fields is already built at) against the
--       family-level count (stock_code with trailing letters stripped,
--       same REGEXP_REPLACE pattern used on the customer side's
--       product diversity fork, Query 89-90), to make an informed
--       grain decision rather than an arbitrary one before Phase 4.
-- WHY: Per the framework, this sprint deliberately does NOT build both
--      grains in full parallel the way the customer side treated every
--      fork -- one query here is meant to settle the question with
--      evidence, then move on. Checking how much consolidation family-
--      level grouping would actually produce is enough to decide
--      whether it's worth a second build or whether variant-level is
--      the obviously correct choice for this sprint's purpose (a
--      warehouse reorders specific SKUs, not abstract product
--      families).

SELECT
    COUNT(DISTINCT stock_code) AS variant_count,
    COUNT(DISTINCT REGEXP_REPLACE(stock_code, '[A-Za-z]+$', '')) AS family_count
FROM uk_retail.stock_behavior_fields;

-- RESULT: variant_count = 4,734, family_count = 3,957 -- a gap of 777
-- SKUs (16.4% consolidation). A real but moderate divergence, not
-- negligible and not overwhelming either way on its own.

-- CONFIRMED FINDING (grain decision): stock_behavior_fields remains at
-- variant-level (stock_code) as the grain for this sprint, WITHOUT
-- building a full parallel family-level table. Rationale: a warehouse
-- reorders specific, physically distinct SKUs (a particular color,
-- size, or design variant), not an abstract product family -- family-
-- level grouping would blur exactly the distinction that makes a
-- reorder-timing signal actionable for purchasing. The 16.4%
-- consolidation figure is noted here as evidence the decision was
-- checked, not assumed, consistent with this project's standing rule,
-- but does not meet the bar for reversing an operationally-motivated
-- default. Family-level remains available as a future fork if a
-- specific need arises, but is deliberately not built now, consistent
-- with this sprint's narrow, petit scope. Phase 3 is closed. Ready for
-- Phase 4's headline findings.

-- [ADDENDUM] Unaffected by the full_transactions double-counting bug
-- (confirmed and fixed at Queries 151b/151c/151d) regardless of when
-- this query was actually run. It touches only stock_code
-- (COUNT DISTINCT and a REGEXP_REPLACE transform of that same column)
-- -- the bug never changed which SKUs existed or their stock_code
-- values, only certain other columns' contents (monetary_gross/net,
-- line_item_return_rate_pct) within rows built pre-fix. This query's
-- result is identical whether it ran against the old or the rebuilt
-- stock_behavior_fields. No rerun needed.