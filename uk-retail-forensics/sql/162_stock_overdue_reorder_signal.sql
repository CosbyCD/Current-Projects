-- Query 162_stock_overdue_reorder_signal

-- WHAT: Headline finding #1. Flags SKUs where current dormancy
--       (recency_days) significantly exceeds the SKU's OWN historical
--       restocking rhythm (avg_interval_fractional_day) -- the direct
--       "overdue for reorder" signal this sprint is built to surface.
--       Uses a 3x multiple as the threshold (recency at least triple
--       the SKU's normal gap between orders) to separate genuine
--       overdue items from ordinary short-term lulls.
-- WHY: This is the purchasing-facing headline finding: which SKUs are
--      most overdue RELATIVE TO THEIR OWN NORMAL PATTERN, not against
--      an arbitrary fixed day count. A SKU that normally sells every
--      3 days and hasn't sold in 15 is a much stronger signal than a
--      SKU that normally sells every 60 days and hasn't sold in 75 --
--      a fixed threshold would treat these as equally urgent when
--      they aren't. Restricted to SKUs with at least 5 completed
--      orders (frequency_completed >= 5) so the "normal rhythm"
--      baseline is meaningful rather than computed from 2-3 data
--      points.

SELECT
    stock_code,
    recency_days,
    frequency_completed,
    avg_interval_fractional_day,
    ROUND((recency_days / NULLIF(avg_interval_fractional_day, 0))::NUMERIC, 1) AS overdue_multiple,
    monetary_net
FROM uk_retail.stock_behavior_fields
WHERE frequency_completed >= 5
  AND avg_interval_fractional_day IS NOT NULL
  AND recency_days >= 3 * avg_interval_fractional_day
ORDER BY overdue_multiple DESC
LIMIT 30;

-- RESULT (verified against pasted CSV): 30 SKUs returned, overdue
-- multiples ranging 494.1x to 1,884.2x their own normal restocking
-- rhythm. The list is genuinely mixed by value, not skewed purely
-- toward low-value long-tail items -- 14 of 30 rows carry over £1,000
-- in historical net revenue. Standout: stock code 37503, £26,556.41
-- net revenue, 523 completed orders historically (sub-half-day average
-- gap between orders), now dormant 359 days -- a 763.8x multiple.
-- Other high-value examples: 22528 (£8,860.74 net, 554 orders, 366
-- days dormant), 79029 (£5,825.14 net, 343 orders, 480 days dormant),
-- 47568 (£5,442.29 net, 410 orders, 421 days dormant).

-- CONFIRMED FINDING: A relative (SKU-own-rhythm) overdue signal
-- successfully separates genuine reorder candidates from ordinary
-- short-term dips -- something a fixed day-count threshold would not
-- have done cleanly, since the flagged SKUs span a wide range of
-- native order frequencies. High-value, high-historical-volume items
-- like 37503, 22528, 79029, and 47568 are the strongest purchasing-
-- facing candidates: substantial proven demand, now conspicuously
-- absent well beyond their own established pattern. This is the
-- restocking-priority half of Phase 4; see Query 163 for the
-- complementary dead-stock/write-off candidate list.

-- [FLAGGED] This query was likely run before stock_behavior_fields was
-- rebuilt against the corrected full_transactions (Query 159's
-- reconstruction, confirmed clean at Query 160). The WHERE and ORDER BY
-- logic here uses only recency_days, frequency_completed, and
-- avg_interval_fractional_day -- all three already confirmed unaffected
-- by the double-counting bug (Queries 153, 154, 156) -- so the set of
-- 30 SKUs selected and their overdue_multiple ranking is NOT at risk
-- and will be identical regardless of when this ran. The one column
-- that IS at risk is monetary_net, pulled directly from
-- stock_behavior_fields and confirmed affected by the bug (Query 155).
-- If this was run pre-fix, the net-revenue figures cited for 37503,
-- 22528, 79029, and 47568 are stale display values, not selection-
-- affecting ones. Needs a rerun to refresh monetary_net only -- the SKU
-- list itself does not need re-deriving.

-- [CONFIRMED via rerun against the rebuilt stock_behavior_fields]
-- Exactly as predicted: identical 30 SKUs, identical order, identical
-- overdue_multiple for every row -- this finding's structure was never
-- actually at risk. Every monetary_net value decreased (never
-- increased), consistent with the duplication having inflated all of
-- them. Corrected figures for the four standout SKUs named in the
-- original write-up: 37503 £26,556.41 -> £24,912.88 (-£1,643.53), 22528
-- £8,860.74 -> £7,567.16 (-£1,293.58), 79029 £5,825.14 -> £5,424.47
-- (-£400.67), 47568 £5,442.29 -> £4,938.05 (-£504.24). Largest single
-- correction in this list: 21780, -£910.30. All 30 corrections ranged
-- -£1.72 to -£1,643.53, no exceptions. The CONFIRMED FINDING above
-- (relative overdue-signal methodology, standout SKU identities) stands
-- unchanged -- only the cited net-revenue dollar figures needed
-- updating, which should be swapped for the corrected values above
-- wherever this finding is referenced downstream (storyboard,
-- README, etc.).