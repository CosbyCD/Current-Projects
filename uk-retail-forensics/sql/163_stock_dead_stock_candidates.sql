-- Query 163_stock_dead_stock_candidates

-- WHAT: Headline finding #2. Flags SKUs with BOTH extreme dormancy
--       (recency_days >= 377 -- reusing the already-vetted "most
--       lapsed" threshold established on the customer side at Query
--       123, for methodological consistency rather than deriving a
--       fresh cutoff) AND low historical demand (frequency_completed
--       <= 3 lifetime orders) -- the write-off/gift-bonus candidate
--       list, deliberately distinct from Query 162's overdue-reorder
--       list.
-- WHY: Query 162 flags high-historical-demand SKUs that are overdue
--      relative to their OWN rhythm -- the restocking-priority signal.
--      This is the opposite case: SKUs that were never strong sellers
--      to begin with AND have been dormant a long time in absolute
--      terms. These aren't "restock urgently" candidates -- they're
--      "this may be dead inventory occupying warehouse space"
--      candidates. Recommending gift/bonus-offer reclassification
--      rather than a straight write-off recovers some value while
--      still freeing the space. The low-frequency threshold (<=3) is a
--      deliberate judgment call for this petit-scope sprint, not an
--      exhaustively derived boundary -- flagged as such rather than
--      presented as more rigorous than it is.

SELECT
    stock_code,
    recency_days,
    frequency_completed,
    monetary_net,
    distinct_customers
FROM uk_retail.stock_behavior_fields
WHERE recency_days >= 377
  AND frequency_completed IS NOT NULL
  AND frequency_completed <= 3
ORDER BY recency_days DESC, monetary_net DESC
LIMIT 30;

-- RESULT (verified against pasted CSV, population size and shape
-- confirmed at Query 164): the 30 rows shown are the most-dormant
-- slice of a 201-SKU total population, sorted by recency then net
-- value. Individually low-value -- the top-30 slice ranges £0.00 to
-- £87.80 net revenue, all at 731-737 days recency. distinct_customers
-- is mostly 1, several NULL (unattributed-only, no customer linkage),
-- max 3 across the full 201-SKU population -- but per Query 164, that
-- ceiling is a structural artifact of the frequency_completed <= 3
-- filter itself (distinct_customers can never exceed
-- frequency_completed), not a genuine finding about broad vs. narrow
-- appeal. This query as designed cannot distinguish "always narrow-
-- interest" from "used to be popular, now dormant" -- it only captures
-- the former by construction.

-- CONFIRMED FINDING: 201 SKUs qualify as dead-stock candidates under
-- this threshold, aggregate historical value £14,025.45 (Query 164),
-- individually low-value and uniformly narrow-interest by construction.
-- Given the modest aggregate value and structural narrowness of this
-- population, the practical recommendation is a simple bundled gift-
-- with-purchase clearance rather than a differentiated broad-appeal
-- marketing push -- this specific population has no broad-appeal
-- subset to target differently. A genuinely different query (decoupling
-- current dormancy from historical popularity, e.g. high lifetime
-- frequency_completed combined with high current recency_days) would
-- be needed to find a "was popular, now dormant" subset -- not pursued
-- here, consistent with this sprint's deliberately narrow scope. This
-- closes Phase 4's dead-stock angle.

-- [REVISION — added per Query 165_dead_stock_seasonality_check, run
-- July 22, 2026: this query's undifferentiated gift-bonus-clearance
-- recommendation is superseded. 93 of the 201 candidates flagged here
-- (46.3%) have their entire order history concentrated in November or
-- December -- genuine seasonal demand, not dead inventory -- confirmed
-- via multi-order clustering far beyond chance (6 SKUs with all 3
-- orders in December, 23 SKUs with both orders in December). Those 93
-- SKUs should be EXCLUDED from write-off/clearance and instead flagged
-- for seasonal restocking. Only the remaining 108 SKUs (201 minus the
-- 93 seasonal ones) are genuine gift-bonus-clearance candidates. See
-- Query 165 for the full account.]
-- [FLAGGED] This query was likely run before stock_behavior_fields was
-- rebuilt against the corrected full_transactions (Query 159's
-- reconstruction, confirmed clean at Query 160). GOOD NEWS FIRST: the
-- 201-SKU population count itself is structurally SAFE -- the WHERE
-- clause filters only on recency_days and frequency_completed, both
-- already confirmed unaffected by the double-counting bug (Queries
-- 153, 154). monetary_net never appears in WHERE, so it cannot have
-- changed which SKUs qualify or the total count. This means the
-- headline 201 figure (and its downstream 93/108 split at Query 165,
-- pending its own review) was very likely never actually at risk.
--
-- Two things still need confirming via rerun, not just reasoning:
-- (1) The top-30 DISPLAY here uses monetary_net as an ORDER BY
-- tiebreaker after recency_days. This CSV has heavy ties (7 SKUs at
-- 737 days, 9 at 736) -- if corrected monetary_net reorders any tied
-- group straddling the LIMIT 30 cutoff, a different SKU could appear
-- in the top 30 than shown here. Not reasoned safe -- needs an actual
-- rerun to confirm the exact 30-row set and order are unchanged.
-- (2) Every displayed monetary_net value is a stale, pre-fix figure and
-- needs refreshing regardless of whether the row set changes.
-- The £14,025.45 aggregate value (cited from Query 164) is a
-- SUM(monetary_net) across the full 201 population -- confirmed
-- affected, will need recalculating when Query 164 is reviewed.

-- [CONFIRMED via rerun against the rebuilt stock_behavior_fields]
-- SKU membership: identical -- all 30 SKUs from the original top-30
-- appear in the corrected top-30, zero additions or drops. Confirms the
-- 201-SKU population itself was never actually at risk, exactly as
-- structurally reasoned above.
--
-- Display order: DID shift within tied recency groups, exactly as
-- flagged. Most visibly: at 737 days (7-way tie), 84648 moved from 4th
-- to 2nd place because its monetary_net (12.75, unaffected -- likely no
-- unattributed activity for this SKU) stayed put while 79070B (22.52 ->
-- 11.26, exactly halved) and 20739 (17.30 -> 8.65, exactly halved) both
-- corrected downward past it. Several SKUs show an exact 50% reduction
-- (79070B, 20739, 30086C, 20737, 21860, 84814B) -- consistent with
-- those specific SKUs' entire displayed order having originated from a
-- single duplicated unattributed transaction, cleanly halved once the
-- duplicate was removed.
--
-- CONFIRMED: this finding's substance is fully intact. The 201-SKU dead
-- -stock population, and by extension its downstream 93-seasonal and
-- 108-genuine splits (Query 165, still pending its own review), were
-- never at risk from the bug -- only this display's internal ordering
-- and dollar values needed correcting, which is now done. The corrected
-- top-30 order and values above should replace the original table
-- wherever this finding is cited going forward.