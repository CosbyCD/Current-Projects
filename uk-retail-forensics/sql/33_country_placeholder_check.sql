-- Query 33_country_placeholder_check

-- ============================================================
-- INVESTIGATION: Country field — placeholder/non-country values
-- WHAT: Checks the country column for values that aren't real
--       country names — blanks, "Unspecified," or similar
--       placeholder entries — across the full dataset.
-- WHY: Thread 5, the last open item from the Phase 5 completeness
--      audit. The audit itself found 0 true blanks/nulls in
--      country, but a populated field can still contain a
--      placeholder value rather than a real country, the same
--      way description contained "check"/"found" instead of a
--      real product name (Thread 3).
-- ============================================================
SELECT country, COUNT(*) AS occurrences
FROM uk_retail.raw_transactions
GROUP BY country
ORDER BY occurrences DESC;

-- RESULT: 41 distinct country values returned, dominated by "United
-- Kingdom" (981,330, ~91.9% of the dataset), followed by a long tail of
-- genuine countries (EIRE, Germany, France, Netherlands, etc.) down to
-- single-digit counts (Saudi Arabia at 10). Confirmed placeholder value:
-- "Unspecified" appears 756 times -- a real, non-trivial population
-- that is technically non-blank (passing the Query 14 completeness
-- audit) but does not represent an actual country, matching the
-- hypothesis exactly. Two additional values are also not literal
-- countries, though less clearly "placeholder" in nature: "European
-- Community" (61 occurrences, a supranational designation rather than
-- a country) and "RSA" (169 occurrences, an abbreviation for Republic
-- of South Africa rather than a standardized country name -- likely a
-- legitimate but non-standard entry rather than an error).

-- CONFIRMED FINDING: Confirms Thread 5's hypothesis -- the country
-- field passing the Query 14 blank/NULL completeness check does not
-- guarantee every value is a genuine country name. "Unspecified" (756
-- rows, ~0.07% of the dataset) is a real placeholder value requiring
-- the same treatment consideration as the "check"/"found" placeholder
-- text found in description (Queries 20-23) -- though at a much smaller
-- scale. "European Community" and "RSA" are edge cases: not
-- placeholders in the sense of missing data, but non-standard
-- geographic entries that would need normalization (RSA -> South
-- Africa) or special handling (European Community as a non-country
-- designation) before country-based analysis could be fully trusted.
-- Given the small scale (756 + 61 + 169 = 986 rows, ~0.09% of the full
-- dataset), this does not warrant exclusion from customer-behavior
-- fields the way the zero-price/no-customer categories did -- these
-- rows still represent real customer transactions with real revenue,
-- just with an imperfect geographic label. Recommend flagging for
-- normalization in a country-cleaning pass rather than exclusion. See
-- Query 34 for the "Unspecified" normalization approach.