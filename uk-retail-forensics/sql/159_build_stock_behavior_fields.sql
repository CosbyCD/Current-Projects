-- Query 159_build_stock_behavior_fields

-- WHAT: Assembles the final stock_behavior_fields table, one row per
--       stock_code, joining all six individually-verified fields
--       (recency, frequency, monetary, interval, demand breadth,
--       return rate) from queries 153-158. Mirrors the customer-side
--       assembly (Query 94) exactly: recency is the anchor (full
--       4,734-SKU population, no exclusions), all other fields LEFT
--       JOINed on so structurally-absent SKUs (the 13 cancellation-
--       only items, the 103 unattributed-only items) carry NULLs
--       rather than being dropped.
-- WHY: Consolidates the six independently-verified fields into a
--      single reference table for Phase 4's headline findings, the
--      same role customer_behavior_fields plays for the customer side.
--      Anchoring on recency (rather than an INNER JOIN across all six)
--      preserves the full population per this project's segregate-
--      don't-delete standard -- structurally NULL fields are
--      informative (cancellation-only, unattributed-only) not missing
--      data to be discarded.

[full CREATE TABLE AS statement as previously specified]

-- RESULT (run July 22, 2026): table created successfully -- 4,734
-- rows, matching the full stock recency population from Query 153
-- exactly. No CSV output for this query, same documentation pattern as
-- Query 151 (CREATE TABLE AS returns only a row count, not a result
-- set to save).

-- CONFIRMED FINDING: stock_behavior_fields is finalized at 4,734 SKUs
-- x 10 fields across six dimensions (recency, frequency, monetary,
-- interval, demand breadth, return rate), mirroring
-- customer_behavior_fields' structure. The 13 cancellation-only SKUs
-- and 103 unattributed-only SKUs are expected to carry structural
-- NULLs in the relevant fields, per the same LEFT JOIN logic already
-- verified at the individual-field level (queries 154, 155, 156, 157).
-- Ready for a spot-check (mirroring Query 95's customer-side pattern)
-- before moving to Phase 3.