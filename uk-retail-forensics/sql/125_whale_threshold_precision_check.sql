-- Query 125_whale_threshold_precision_check
-- WHAT: Pull every customer in the most-lapsed recency quartile with
--       monetary_net within a few pounds of the £2,180.28 whale
--       threshold established in query 122, showing the value to full
--       precision, to check whether the boundary customer's exact value
--       could cause a floating-point comparison mismatch in Tableau.
-- WHY: Query 124 ruled out the 377-day recency tie as the cause of
--      Tableau's 58-vs-59 discrepancy against queries 115/122. The next
--      candidate is floating-point precision: if £2,180.28 is one
--      customer's exact value, a live-connection type mismatch between
--      PostgreSQL's numeric storage and Tableau's internal float
--      representation could cause a ">=2180.28" comparison to exclude
--      that customer even though they belong in the whale tier.

SELECT
    customer_id,
    recency_days,
    monetary_net,
    monetary_net::text AS monetary_net_full_precision
FROM uk_retail.customer_behavior_fields
WHERE recency_days >= 377
  AND monetary_net BETWEEN 2170 AND 2200
ORDER BY monetary_net ASC;

-- RESULT (run July 18, 2026):
-- Two customers fall within £10 of the £2,180.28 whale threshold, both
-- with recency >= 377 days:
--   15476: recency 379, monetary_net £2,180.28 (exact threshold value)
--   15934: recency 417, monetary_net £2,190.66
--
-- CONFIRMED FINDING: Customer 15476 was flagged as the likely source of
-- Tableau's 58-vs-59 discrepancy due to sitting exactly at the £2,180.28
-- boundary, a plausible floating-point precision issue. This hypothesis
-- was tested directly by isolating customer 15476 alone in Tableau
-- (filtered to Customer Id = 15476), which showed monetary_net correctly
-- computing to £2,180.28 and the "Recency-Monetary Tier (Rev.
-- Q105/106/122)" field correctly returning "Lapsed Whale" for this
-- customer. The floating-point precision hypothesis is RULED OUT --
-- 15476 is not the missing customer. The 58-vs-59 discrepancy remains
-- unexplained; see Query 126 for the full ground-truth list, compared
-- directly against Tableau's output rather than continuing to test
-- individual hypotheses.