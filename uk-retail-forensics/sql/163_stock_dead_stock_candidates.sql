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