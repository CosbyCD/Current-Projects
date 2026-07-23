-- Query 172_phase5_exhibit_data_pull

-- WHAT: Combines all three Phase 4 headline categories into a single
--       labeled dataset for the Chapter Five exhibit.
-- WHY: One exhibit, three meaningful categories, no gray backdrop.

[query as previously specified]

-- RESULT (verified against pasted CSV): 1,733 rows total -- 1,532
-- Overdue Restock, 108 Dead Stock Candidate, 93 Seasonal Dormant. The
-- Dead Stock / Seasonal split confirms exactly against Query 164/165
-- (108 + 93 = 201). However, Overdue Restock at 1,532 rows (88% of the
-- exhibit) inherits the same over-loose threshold problem flagged at
-- Query 171 -- this pull is NOT ready for the exhibit as-is.

-- CONFIRMED FINDING: category-assignment logic is correct and verified
-- for the two dead-stock-derived categories. Superseded pending Query
-- 162's threshold retightening -- rerun with the corrected Overdue
-- Restock definition before this feeds the actual exhibit.