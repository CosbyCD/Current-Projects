-- Query 123_lapsed_recency_quartile_threshold_check
-- WHAT: Find the recency_days value at the boundary between quartile 3
--       and quartile 4 (recency) -- the actual cutoff defining the
--       "most lapsed" recency quartile used throughout the funnel
--       verification (queries 106, 115, 122), to replace the guessed
--       400-day cutoff proposed for the Tableau "Funnel Tier" field.
-- WHY: Query 122 corrected the monetary threshold for the lapsed-whale
--      tier from a guessed £5,000 to the actual £2,180.28 boundary. The
--      companion recency threshold (guessed at 400 days) has not yet
--      been checked against the real quartile boundary the rest of this
--      verification pass has been using. Per this project's standing
--      rule, this replaces the guess with the real number before the
--      Tableau field is finalized.

WITH quartiled AS (
    SELECT
        customer_id,
        recency_days,
        NTILE(4) OVER (ORDER BY recency_days) AS recency_quartile
    FROM uk_retail.customer_behavior_fields
    WHERE recency_days IS NOT NULL
)
SELECT
    MIN(recency_days) FILTER (WHERE recency_quartile = 4) AS lapsed_threshold_min,
    MAX(recency_days) FILTER (WHERE recency_quartile = 4) AS lapsed_max,
    MAX(recency_days) FILTER (WHERE recency_quartile = 3) AS just_below_threshold,
    COUNT(*) FILTER (WHERE recency_quartile = 4) AS quartile_4_count
FROM quartiled;

-- RESULT (run July 18, 2026):
-- Recency quartile 4 (most lapsed) begins at 377 days and ranges up to
-- 738 days, containing 1,468 customers. The just_below_threshold value
-- also shows 377 -- a tie at the exact boundary, expected behavior when
-- NTILE splits customers sharing the same recency value across adjacent
-- quartiles on a non-evenly-divisible dataset.
--
-- CONFIRMED FINDING: The actual recency_days threshold defining the
-- most-lapsed quartile is 377 days, close to but not identical to the
-- guessed 400-day cutoff proposed for the Chapter Four Tableau "Funnel
-- Tier" calculated field. The Tableau field should use 377 (not 400) for
-- consistency with the quartile boundaries already established in
-- queries 106, 115, and 122.
--
-- [CROSS-REFERENCE — added following Query 127_whale_definition_
-- discrepancy_check, run July 18, 2026: the tie noted above at line 33
-- (just_below_threshold also equaling 377) was the first visible sign of
-- the NTILE non-determinism issue Query 127 later confirmed directly --
-- customer 13542 (recency_days = 376) was found in recency_quartile 4
-- despite this query reporting 377 as that quartile's minimum. The
-- NTILE(4) OVER (ORDER BY recency_days) function used here lacks a
-- secondary tiebreaker and is not guaranteed reproducible on rerun. The
-- 377-day threshold value itself remains the correct one adopted for the
-- fixed dual-threshold definition used in Chapter Four (queries 122/126,
-- 58 customers) — only the underlying NTILE quartile mechanism is flagged
-- as non-deterministic, not this query's reported threshold.]

-- [ADDENDUM — added July 22, 2026, independent of Query 127: cross-
-- checking this query's stated recency-quartile-4 population against
-- Query 106 and Query 115 (which both run NTILE(4) OVER (ORDER BY
-- recency_days) over what should be the identical 5,852-customer
-- population) surfaces a second, independent instance of the NTILE
-- non-determinism issue Query 127 later formally diagnoses: Query 106's
-- RQ4 total is 1,465; Query 115's is 1,463 — a 2-customer gap over an
-- identical population and identical ORDER BY clause. Not previously
-- documented in either query's own write-up or in Query 127.]