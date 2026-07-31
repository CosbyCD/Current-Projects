-- Query 157_stock_demand_breadth

-- WHAT: Fifth field of stock_behavior_fields: distinct_customers, the
--       count of unique customers who purchased each SKU on a
--       completed order. Repurposes the customer-side diversity field's
--       structure (distinct count of a related dimension) for the
--       stock side.
-- WHY: Sourced from clean_transactions, NOT full_transactions -- this
--      is a deliberate scope narrowing, not an error. full_transactions
--      (Query 151) dropped customer_id entirely as part of the union,
--      since unattributed_transactions never had one -- there is no
--      customer dimension left to count in that table. Demand breadth
--      is inherently a customer-attributed-only metric, the same way
--      full_transactions was built specifically because the OTHER
--      fields (recency, frequency, monetary, interval) don't care about
--      customer identity and benefit from the full pool. This field
--      measures demand concentration vs. breadth: a SKU bought once by
--      many different customers reads differently (broad appeal) than
--      the same total quantity bought by a handful of repeat buyers
--      (concentrated demand) -- relevant for whether a "dead stock"
--      candidate (Phase 4) ever had broad appeal worth re-promoting via
--      a gift/bonus offer, or was always a narrow-interest item.

SELECT
    stock_code,
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
  AND invoice_no NOT LIKE 'C%'
GROUP BY stock_code
ORDER BY stock_code;

-- RESULT (verified against pasted CSV): 4,618 rows -- 103 fewer than
-- Query 154's 4,721-SKU full_transactions population. Confirmed every
-- one of the 4,618 codes here is a proper subset of Query 154's SKUs
-- (zero unexpected additions). The 103-SKU gap represents items whose
-- only completed-order activity came entirely from
-- unattributed_transactions (real sales, no customer_id attached) --
-- expected given this field's deliberate scope narrowing to the
-- customer-attributed subset. distinct_customers ranges 1 to 1,490 --
-- the SKU with 1,490 distinct buyers is the broadest-appeal single item
-- in the dataset, worth flagging as a candidate for Phase 4 if a
-- broad-appeal contrast to a narrow-interest item would strengthen that
-- write-up.

-- CONFIRMED FINDING: Stock-side demand breadth is built and verified
-- for 4,618 customer-attributed SKUs. The 103-SKU gap is fully
-- explained and expected, not a data-quality concern. Ready for return
-- rate (Query 158), the last individual field before assembly.

-- [ADDENDUM] Unlike Queries 153-156, this field was never exposed to the
-- full_transactions double-counting bug (confirmed and fixed at Queries
-- 151b/151c/151d) in the first place -- its WHY block already states it
-- sources from clean_transactions directly, not full_transactions.
-- clean_transactions itself was never affected by that bug; the
-- duplication was specific to how full_transactions unioned
-- clean_transactions with unattributed_transactions (which clean_
-- transactions was never part of). No rerun needed and no reasoning
-- chain required -- the buggy table simply isn't in this query's
-- lineage.
SELECT
    stock_code,
    COUNT(DISTINCT customer_id) AS distinct_customers
FROM uk_retail.clean_transactions
WHERE customer_id IS NOT NULL
  AND invoice_no NOT LIKE 'C%'
GROUP BY stock_code
ORDER BY stock_code;

-- RESULT (verified against pasted CSV): 4,618 rows -- 103 fewer than
-- Query 154's 4,721-SKU full_transactions population. Confirmed every
-- one of the 4,618 codes here is a proper subset of Query 154's SKUs
-- (zero unexpected additions). The 103-SKU gap represents items whose
-- only completed-order activity came entirely from
-- unattributed_transactions (real sales, no customer_id attached) --
-- expected given this field's deliberate scope narrowing to the
-- customer-attributed subset. distinct_customers ranges 1 to 1,490 --
-- the SKU with 1,490 distinct buyers is the broadest-appeal single item
-- in the dataset, worth flagging as a candidate for Phase 4 if a
-- broad-appeal contrast to a narrow-interest item would strengthen that
-- write-up.

-- CONFIRMED FINDING: Stock-side demand breadth is built and verified
-- for 4,618 customer-attributed SKUs. The 103-SKU gap is fully
-- explained and expected, not a data-quality concern. Ready for return
-- rate (Query 158), the last individual field before assembly.